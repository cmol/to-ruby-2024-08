# frozen_string_literal: true

require 'socket'

CONNECT_ADDR = 'localhost'
CONNECT_PORT = 12_345
MSG_LENGTH  = 256
FLAGS       = 0

Addrinfo.udp(CONNECT_ADDR, CONNECT_PORT).connect do |socket|
  socket.send('Connected via unspecified address family socket', FLAGS)
  message, _server = socket.recvfrom(MSG_LENGTH)
  puts message
end

Socket.getaddrinfo(CONNECT_ADDR, CONNECT_PORT, :AF_UNSPEC, :DGRAM).each do |con|
  af, port, _hostname, ip, _pf, _sock_type, _ipproto = con
  Addrinfo.udp(ip, port).connect do |socket|
    socket.send("Connected via #{af}", FLAGS)
    message, _server = socket.recvfrom(MSG_LENGTH)
    puts message
  end
end
