# -*- coding: utf-8 -*-
require 'sequel'

config.plugins.db.set_default(:path, Termtter::CONF_DIR + '/termtter.db')

DB = Sequel.sqlite(config.plugins.db.path) unless defined? DB

unless DB.table_exists?(:statuses)
  DB.create_table :statuses do
    primary_key :id
    Integer :user_id
    String :text
    String :source
    String :created_at
    Integer :in_reply_to_status_id
    Integer :in_reply_to_user_id
  end
end

unless DB.table_exists?(:users)
  DB.create_table :users do
    primary_key :id
    String :screen_name
    boolean :protected
  end
end

class Status < Sequel::Model(:statuses)
  many_to_one :user
end

class User < Sequel::Model(:users)
  one_to_many :statuses

  def self.find_or_fetch(args)
    record = self.find(args)
    return record if record
    if key = (args[:id] || args[:screen_name])
      fetched = Termtter::API.twitter.user(key) # XXX: throws Rubytter::APIError
      User << {
        :id => fetched.id,
        :screen_name => fetched.screen_name,
        :protected => fetched.protected
      }
      self.find(args)
    end
  end
end

module Termtter
  module Client
    register_hook(:collect_statuses_for_db, :point => :pre_filter) do |statuses, event|
      statuses.each do |s|

        # Save statuses
        if Status.filter(:id => s.id).empty?
          status = {}
          Status.columns.each do |col|
            status[col] =
              case col
              when :user_id
                s.user.id
              else
                s[col] rescue nil
              end
          end
          Status << status
        end

        # Save users
        if User.filter(:id => s.user.id).empty?
          user = {}
          User.columns.each do |col|
            user[col] =
              if event.class == SearchEvent && col == :protected
                false
              else
                s.user[col]
              end
          end
          User << user
        end

      end
    end

    register_command(:db_search, :alias => :ds) do |arg|
      statuses = Status.filter(:text.like("%#{arg}%")).limit(20)
      output(statuses, :db_search)
    end

    register_command(:db_clear) do |arg|
      if confirm('Are you sure?')
        User.delete
        Status.delete
      end
    end

    register_command(:db_list) do |arg|
      user_name = normalize_as_user_name(arg)
      statuses = Status.join(:users, :id => :user_id).filter(:users__screen_name => user_name).limit(20)
      output(statuses, :db_search)
    end

    register_command(:db_execute) do |arg|
      DB.execute(arg).each do |row|
        p row
      end
    end
  end
end
