require 'json'
require 'socket'

class RubyLSPServer
  def start
    server = TCPServer.new('localhost', 8080)
    puts 'Ruby LSP Server started on port 8080'

    loop do
      Thread.start(server.accept) do |client|
        handle_client(client)
      end
    end
  end

  private

  def handle_client(client)
    puts 'Client connected'

    loop do
      header = client.gets("\r\n\r\n")
      break unless header

      content_length = header[/Content-Length: (\d+)/, 1].to_i
      data = client.read(content_length)

      request = JSON.parse(data)
      response = handle_request(request)

      send_response(client, response) if response
    end

    puts 'Client disconnected'
    client.close
  end

  def handle_request(request)
    case request['method']
    when 'initialize'
      { id: request['id'], result: { capabilities: { hoverProvider: true } } }
    when 'textDocument/hover'
      handle_hover(request)
    else
      nil
    end
  end

  def handle_hover(request)
    # Example hover response for a specific keyword
    if request.dig('params', 'textDocument', 'uri').end_with?('.sl') && request.dig('params', 'position', 'line') == 0
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

  def send_response(client, response)
    response_body = response.to_json
    headers = [
      "Content-Length: #{response_body.bytesize}",
      "Content-Type: application/vscode-jsonrpc; charset=utf-8",
    ]

    client.puts(headers.join("\r\n"))
    client.puts("\r\n")
    client.puts(response_body)
  end
end

RubyLSPServer.new.start
