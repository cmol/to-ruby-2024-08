# frozen_string_literal: true

require 'socket'

CONNECT_ADDR = 'localhost'
CONNECT_PORT = 12_345

socket = TCPSocket.new(CONNECT_ADDR, CONNECT_PORT)
puts "Connected to #{socket.remote_address.ip_address}"
socket.puts 'Connected via unspecified address family socket'
puts socket.gets
socket.close
