require 'socket'
require 'json'

def server_response(socket, header, body)
	socket.print("#{header}\r\n\r\n#{body}")
end

def parse_request(client)
	
end

server = TCPServer.open(2000)
loop {
  client = server.accept
  request = client.read_nonblock(512)
  headers, body = request.split("\r\n\r\n")
	type, path, version = headers.split(" ", 4)
  if File.exist?(path)
	  case type
	  when "GET" then
		  File.open(path, "r") { |file|
		  	send_body = file.read
		  	send_headers = "#{version} 200 OK\r\n"\
		  						"Date: #{Time.now.ctime}\r\n"\
		  						"Content-Type: text.html\r\n"\
		  						"Content-Length: #{send_body.length}"
		  	server_response(client, send_headers, send_body)
		  }
		when "POST" then
			params = JSON.parse("#{body}")
		  File.open(path, "r") { |file|
		  	send_body = file.read
		  	send_body.gsub!("<%= yield %>", "<li>Name: #{params['viking']['name']}</li>"\
		  																 "<li>Email: #{params['viking']['email']}</li>")
		  	send_headers = "#{version} 200 OK\r\n"\
		  								 "Date: #{Time.now.ctime}\r\n"\
		  								 "Content-Type: text.html\r\n"\
		  								 "Content-Length: #{send_body.length}"
		  	server_response(client, send_headers, send_body)
		  }
		else
	  	send_headers = "#{version} 400 Bad Request\r\n"\
		  					"Date: #{Time.now.ctime}"
		  send_body = "Unrecognized request."
		  server_response(client, send_headers, send_body)
	  end
	else
		send_headers = "#{version} 404 Not Found\r\n"\
		  						"Date: #{Time.now.ctime}"
		send_body = "Path does not exist on server."
		server_response(client, send_headers, send_body)
	end

  client.close
}