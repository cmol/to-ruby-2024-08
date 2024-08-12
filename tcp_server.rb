# frozen_string_literal: true

require 'socket'

LISTEN_ADDR = '::'
LISTEN_PORT = 12_345

server_socket = TCPServer.new(LISTEN_ADDR, LISTEN_PORT)

loop do
  # Accept client TCP connection
  client_socket = server_socket.accept

  # Get the AddrInfo object and log connection
  addr_info = client_socket.connect_address
  puts "Client connected from #{addr_info.ip_address} using " +
       (addr_info.ipv6_v4mapped? ? 'IPv4' : 'IPv6')

  # Write back to client with AddressFamily and reversed original message
  client_socket.puts(
    "[#{addr_info.ipv6_v4mapped? ? 'IPv4' : 'IPv6'}] #{client_socket.gets.chomp}"
  )
  client_socket.close
end
