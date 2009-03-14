# -*- coding: utf-8 -*-

module Termtter
  class Connection
    attr_reader :protocol, :port, :proxy_uri

    def initialize
      @proxy_host = config.proxy.host
      @proxy_port = config.proxy.port
      @proxy_user = config.proxy.user_name
      @proxy_password = config.proxy.password
      @proxy_uri = nil
      @enable_ssl = config.enable_ssl
      @protocol = "http"
      @port = 80

      unless @proxy_host.empty?
        @http_class = Net::HTTP::Proxy(@proxy_host, @proxy_port,
                                       @proxy_user, @proxy_password)
        @proxy_uri =  "http://" + @proxy_host + ":" + @proxy_port + "/"
      else
        @http_class = Net::HTTP
      end

      if @enable_ssl
        @protocol = "https"
        @port = 443
      end
    end

    def start(host, port, &block)
      http = @http_class.new(host, port)
      http.use_ssl = @enable_ssl
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
      http.start(&block)
    end
  end
end

