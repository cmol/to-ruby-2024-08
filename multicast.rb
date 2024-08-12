# frozen_string_literal: true

require 'socket'
require 'ipaddr'

def get_interface_info(name)
  ifaddrs = Socket.getifaddrs.reject do |ifaddr|
    !ifaddr.addr&.ipv6_linklocal? || (ifaddr.flags & Socket::IFF_MULTICAST).zero?
  end
  ifaddrs.select! { |ifaddr| ifaddr.name == name } if name
  ifaddrs.map { |ifaddr| [ifaddr.name, ifaddr.ifindex, ifaddr.addr.ip_address] }
end

# Set-up and prepare socket
def create_socket(multicast_addr, multicast_port, ifindex)
  UDPSocket.new(Socket::AF_INET6).tap do |s|
    ip = IPAddr.new(multicast_addr).hton + [ifindex].pack('I')
    s.setsockopt(Socket::IPPROTO_IPV6, Socket::IPV6_JOIN_GROUP, ip)
    s.setsockopt(Socket::IPPROTO_IPV6, Socket::IPV6_MULTICAST_HOPS, [1].pack('I'))
    s.setsockopt(Socket::IPPROTO_IPV6, Socket::IPV6_MULTICAST_IF, [ifindex].pack('I'))
    s.bind('::', multicast_port)
  end
end

# Sender thead
def send_request(socket, linklocal_addr, multicast_addr, multicast_port,
                 flags)
  Thread.new do
    # Ensure that we are listening before talking
    sleep 0.1
    puts "========= Sending echo REQUEST from #{linklocal_addr}"
    socket.send("[REQUEST] Hello from #{linklocal_addr}",
                flags, multicast_addr, multicast_port)
  end
end

def echo_listener(socket, linklocal_addr, multicast_addr, multicast_port,
                  flags, msg_length)
  loop do
    # Listen for messages of up to specified length
    message, client = socket.recvfrom(msg_length)

    # Extract client information given as array and log connection
    addr_info = Addrinfo.new(client)

    # We are not interested in messages from our selves
    next if addr_info.ip_address == linklocal_addr

    # Write out the received message
    puts message

    # Only reply if a request is send. If not, we will make infinite packet
    # loops in our network
    next unless message.split.first == '[REQUEST]'

    puts "========= Sending echo REPLY to #{addr_info.ip_address}"
    socket.send("[REPLY]   Hello from #{addr_info.ip_address}",
                flags, multicast_addr, multicast_port)
  end
end

if __FILE__ == $PROGRAM_NAME
  MULTICAST_ADDR = 'ff02::beeb'
  MULTICAST_PORT = 12_345
  MSG_LENGTH     = 256
  FLAGS          = 0

  # Call with interface name if you want to use another interface than the
  # first one presented from getifaddrs
  interface_name, ifindex, linklocal_addr = get_interface_info(ARGV[0]).first
  puts "Using local interface #{interface_name} with address #{linklocal_addr}"

  socket = create_socket(MULTICAST_ADDR, MULTICAST_PORT, ifindex)
  send_request(socket, linklocal_addr, MULTICAST_ADDR, MULTICAST_PORT, FLAGS)
  echo_listener(socket, linklocal_addr, MULTICAST_ADDR, MULTICAST_PORT, FLAGS,
                MSG_LENGTH)
end
