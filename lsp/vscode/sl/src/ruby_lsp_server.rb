  require 'json'
  require 'io/console'

  # TODO: change require off of absolute

  STOUTLANG_PATH = '/Users/ryanstout/Sites/stoutlang/stoutlang'
  require STOUTLANG_PATH

  class RubyLSPServer
    def initialize
      @documents = {}
    end

    def start
      warn "Started LSP"

      loop do
        handle_stdin_input
      end
    end

    private

    def handle_stdin_input
      header = STDIN.gets("\r\n\r\n")
      unless header
        warn "Failed to parse header"
        return unless header
      end

      content_length = header[/Content-Length: (\d+)/, 1].to_i
      data = STDIN.read(content_length)

      request = JSON.parse(data)
      response = handle_request(request)
      if response
        send_response(response)
      end
    end

    def handle_request(request)
      warn "Request: #{request.inspect}"
      case request['method']
      when 'initialize'
        { "jsonrpc" => '2.0', "id" => request['id'], "result" => { "capabilities" => { "hoverProvider" => true, "textDocumentSync" => 1 } } }
      when 'textDocument/hover'
        handle_hover(request)
      when 'textDocument/didOpen'
        handle_did_open(request)
      when 'textDocument/didChange'
        handle_did_change(request)
      when 'textDocument/didClose'
        handle_did_close(request)
      when 'textDocument/hover'
        handle_hover(request)
      else
        # { id: request['id'], error: { code: -32601, message: "Method not found" } }
        warn("Method not found: #{request['method']}")
        nil
      end
    end

    def handle_did_open(request)
      warn "Document opened: #{request.inspect}"
      uri = request['params']['textDocument']['uri']
      content = request['params']['textDocument']['text']
      @documents[uri] = content
      nil
    end

    def handle_did_change(request)
      warn "Document changed: #{request.inspect}"
      uri = request['params']['textDocument']['uri']
      changes = request['params']['contentChanges']
      document_content = @documents[uri]

      changes.each do |change|
        if change['range']
          # Apply partial change
          start_line, start_character = change['range']['start'].values_at('line', 'character')
          end_line, end_character = change['range']['end'].values_at('line', 'character')

          # Convert the document content into an array of lines
          content_lines = document_content.split("\n")

          # Apply change
          if start_line == end_line
            content_lines[start_line][start_character...end_character] = change['text']
          else
            start_line_text = content_lines[start_line][0...start_character]
            end_line_text = content_lines[end_line][end_character..-1] || ""
            middle_text = change['text']

            content_lines[start_line..end_line] = [start_line_text + middle_text + end_line_text]
          end

          # Reassemble the document
          document_content = content_lines.join("\n")
        else
          # Apply full document change
          document_content = change['text']
        end
      end

      @documents[uri] = document_content
      nil
    end

    def handle_did_close(request)
      warn "Document closed: #{request.inspect}"
      uri = request['params']['textDocument']['uri']
      @documents.delete(uri)
      nil
    end

    def handle_hover(request)
      # Example hover response for a specific keyword
      uri = request.dig('params', 'textDocument', 'uri')
      document_content = @documents[uri]
      position = request.dig('params', 'position')
      line = position['line']
      character = position['character']

      # TODO: speed this up or make ranges based on lines and characters
      lines = document_content.split("\n")
      total_characters_position = lines[0...line].sum { |line| line.length + 1 } # +1 for newline characters
      total_characters_position = total_characters_position + character

      warn("Parse #{document_content}")
      parser = StoutLang.parse(document_content)
      parser.ast.prepare
      nodes = parser.nodes_at_cursor(total_characters_position)

      if request.dig('params', 'textDocument', 'uri').end_with?('.sl')
        # If the first node has a effects method, return the effects only
        node = nodes.last.data
        if node.is_a?(StoutLang::Ast::Scope)
          effects = node.effects

          {
            id: request['id'],
            result: {
              contents: {
                kind: 'markdown',
                value: "```ruby\n#{{'effects' => effects}.inspect}\n```"
              }
            }
          }
        else
          {
            id: request['id'],
            result: {
              contents: {
                kind: 'markdown',
                value: "```ruby\n#{node.inspect}\n```"
              }
            }
          }
        end
      else
        { id: request['id'], result: nil }
      end
    end

    def send_response(response)
      response_body = response.to_json
      headers = [
        "Content-Length: #{response_body.bytesize}",
        "Content-Type: application/vscode-jsonrpc; charset=utf-8",
      ]

      warn("Write: #{headers.join("\r\n")}\r\n\r\n#{response_body} -- #{response_body[1].inspect}")

      STDOUT.write(headers.join("\r\n"))
      STDOUT.write("\r\n")
      STDOUT.write("\r\n")
      STDOUT.write(response_body)
      STDOUT.flush
    end
  end

  RubyLSPServer.new.start
