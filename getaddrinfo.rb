# frozen_string_literal: true

require 'socket'

pp Socket.getaddrinfo('localhost', 12_345, :AF_UNSPEC, :STREAM)
