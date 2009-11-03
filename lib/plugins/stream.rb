# -*- coding: utf-8 -*-

require 'uri'
require 'tweetstream'
require 'lib/termtter/active_rubytter'

config.plugins.stream.set_default :max_following, 400

module Termtter::Client

  class << self
    if defined?(DB)
      def friends(max = 1/0.0)
        Status.group(:user_id).
          select(:user_id, :screen_name).
          join(:users, :id => :user_id).
          order(:COUNT.sql_function.desc).
          take(max)
      end
    else
      def friends(max = 1/0.0)
        friends = []
        page    = 0
        begin
          friends += tmp = Termtter::API::twitter.friends(config.user_name, :page => page+=1)
          p friends.length
        rescue
        end until (tmp.empty? or friends.length > max)
        friends.take(max)
      end
    end
  end

  register_command(:stream) do |arg|

    catch(:exit) do
      args = arg.split

      case args[0]
      when ':stop'
        config.plugins.stream.followed_users = []
        config.plugins.stream.thread.kill rescue nil
        puts 'stream is down'
        throw :exit
      when ':followers'
        p config.plugins.stream.followed_users
        throw :exit
      end

      throw :exit unless config.plugins.stream.thread.empty?

      targets = args.map do |name|
        Termtter::API.twitter.user(name).id
      end

      if targets.empty?
        id_method =  defined?(DB) ? :user_id : :id

        max = config.plugins.stream.max_following
        config.plugins.stream.followed_users = []
        friends(config.plugins.stream.max_following).each do |t|
          config.plugins.stream.followed_users << t[:screen_name]
          targets << t.__send__(id_method)
        end
        p config.plugins.stream.followed_users
        puts "streaming #{targets.length} friends."
      end

      config.plugins.stream.thread = Thread.new do
        begin
          puts "try to get #{targets.length} friends streams"
          TweetStream::Client.new(config.user_name, config.password).
            filter(:follow => targets) do |status|
            output [Termtter::ActiveRubytter.new(status)], :stream_output
          end
        rescue => e
          puts "streaming seems broken."

          config.plugins.stream.max_following -= 10

          if config.plugins.stream.max_following > 10
            config.plugins.stream.followed_users =
              config.plugins.stream.followed_users.take(
                config.plugins.stream.max_following)
            targets = targets.take(
                config.plugins.stream.max_following)
            retry
          end
        end
      end

      at_exit do
        config.plugins.stream.thread.kill
      end
    end
  end
end

