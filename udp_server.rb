# frozen_string_literal: true

require 'socket'

LISTEN_ADDR = '::'
LISTEN_PORT = 12_345
MSG_LENGTH  = 256
FLAGS       = 0

# Create socket and bind it to the listen on all addresses and the given port
server_socket = UDPSocket.new :INET6
server_socket.bind(LISTEN_ADDR, LISTEN_PORT)

loop do
  # Listen for messages of up to specified length
  message, client = server_socket.recvfrom(MSG_LENGTH)

  # Extract client information given as array and log connection
  addr_info = Addrinfo.new(client)
  puts "Client connected from #{addr_info.ip_address} using " +
       (addr_info.ipv6_v4mapped? ? 'IPv4' : 'IPv6')

  # Write back to client with AddressFamily and reversed original message
  server_socket.send(
    "[#{addr_info.ipv6_v4mapped? ? 'IPv4' : 'IPv6'}] #{message.chomp.reverse}",
    FLAGS,
    addr_info.ip_address,
    addr_info.ip_port
  )
end
