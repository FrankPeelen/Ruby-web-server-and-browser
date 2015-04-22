require 'socket'
require 'json'

def print_response(headers, body)
	header = headers.split(" ", 3)
	status = header[1]
	case status
	when "200" then print body
	when "404" then print "Error: #{body}"
	else print "Error connecting to the server."
	end
end

def enter_request
	loop do
		puts "Please enter a valid HTTP Request such as 'GET index.html' or"
		puts "'POST thanks.html' to send to the server. Entering HTTP version is not necessary."
		input = gets.chomp
		return input if input.split(" ").size == 2
	end
end


def send_request(socket, headers, body)
	socket.print("#{headers}\r\n\r\n#{body}")
end
 
host = 'localhost'
port = 2000
type, path = enter_request.split(" ")

if type == "GET"
	headers = "#{type} #{path} HTTP/1.0"
	body = ""
	socket = TCPSocket.open(host,port)
	send_request(socket, headers, body)
elsif type == "POST"
	print "To register for the Viking Raid, please enter your name: "
	name = gets.chomp
	print "Please also enter your email address: "
	email = gets.chomp
	post_data = { :viking => { :name => name, :email => email } }
	body = post_data.to_json
	headers = "#{type} #{path} HTTP/1.0\r\n"\
						"Content-Type: json\r\n"\
						"Content-Length: #{body.length}"
	socket = TCPSocket.open(host,port)
	send_request(socket, headers, body)
end

response = socket.read
headers,body = response.split("\r\n\r\n", 2)
print_response(headers, body)