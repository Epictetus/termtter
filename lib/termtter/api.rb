# -*- coding: utf-8 -*-
gem 'rubytter', '>= 0.6.5'
require 'rubytter'

config.set_default(:host, 'twitter.com')
config.proxy.set_default(:port, '8080')
config.proxy.set_default(:host, nil)
config.proxy.set_default(:port, nil)
config.proxy.set_default(:user_name, nil)
config.proxy.set_default(:password, nil)
config.set_default(:enable_ssl, false)

module Termtter
  module API
    class << self
      attr_reader :connection, :twitter
      def setup
        @connection = Connection.new
        if config.access_token.empty? && config.access_token_secret.empty?
          @twitter = Rubytter.new(config.user_name, config.password, twitter_option)
        else
          consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site => 'http://twitter.com')
          access_token = OAuth::AccessToken.new(consumer, config.access_token, config.access_token_secret)
          @twitter = OAuthRubytter.new(access_token, twitter_option)
        end
      end

      def restore_user
        @twitter = create_twitter(config.user_name, config.password)
      end

      def switch_user(username = nil)
        highline = create_highline
        username = highline.ask('your twitter username: ') if username.nil? || username.empty?
        password = highline.ask('your twitter password: ') { |q| q.echo = false }
        @twitter = create_twitter(username, password)
      end

      def twitter_option
        {
          :app_name => config.app_name.empty? ? Termtter::APP_NAME : config.app_name,
          :host => config.host,
          :header => {
            'User-Agent' => 'Termtter http://github.com/jugyo/termtter',
            'X-Twitter-Client' => 'Termtter',
            'X-Twitter-Client-URL' => 'http://github.com/jugyo/termtter',
            'X-Twitter-Client-Version' => Termtter::VERSION
          },
          :enable_ssl => config.enable_ssl,
          :proxy_host => config.proxy.host,
          :proxy_port => config.proxy.port,
          :proxy_user_name => config.proxy.user_name,
          :proxy_password => config.proxy.password
        }
      end
    end
  end
end
# Termtter::API.connection, Termtter::API.twitter can be accessed.
