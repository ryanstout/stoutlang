  require 'json'
  require 'io/console'

  class RubyLSPServer

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
        { id: request['id'], error: { code: -32601, message: "Method not found" } }
      end
    end

    def handle_did_open(request)
      warn "Document opened: #{request.inspect}"
      # Handle the document opening here
      nil
    end

    def handle_did_change(request)
      warn "Document changed: #{request.inspect}"
      # Handle the document change here
      nil
    end

    def handle_did_close(request)
      warn "Document closed: #{request.inspect}"
      # Handle the document closing here
      nil
    end

    def handle_hover(request)
      # Example hover response for a specific keyword
      if request.dig('params', 'textDocument', 'uri').end_with?('.sl')
        {
          id: request['id'],
          result: {
            contents: {
              kind: 'markdown',
              value: 'Hover message for the Ruby file!'
            }
          }
        }
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
