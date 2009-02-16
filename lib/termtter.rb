# -*- coding: utf-8 -*-

$KCODE="u" unless Object.const_defined? :Encoding

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'json'
require 'net/https'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'
require 'configatron'

require 'termtter/twitter'
require 'termtter/connection'
require 'termtter/status'
require 'termtter/user'
require 'termtter/command'
require 'termtter/hook'
require 'termtter/task'
require 'termtter/task_manager'
require 'termtter/client'
require 'termtter/api'
require 'termtter/system_extensions'
require 'termtter/version'

module Termtter
  APP_NAME = 'termtter'
  CONF_FILE = '~/.termtterrc' # still does not use
  CONF_DIR = '~/.termtter' # still does not use
end

if RUBY_VERSION < '1.8.7'
  class Array
    def take(n) self[0...n] end
  end
end

def plugin(s, init = {})
  unless init.empty?
    init.each do |key, value|
      eval("configatron.plugins.#{s}").__send__("#{key}=", value)
    end
  end
  require "plugin/#{s}"
rescue => e
  Termtter::Client.handle_error(e)
end

def filter(s)
  load "filter/#{s}.rb"
rescue => e
  Termtter::Client.handle_error(e)
else
  Termtter::Client.public_storage[:filters] ||= []
  Termtter::Client.public_storage[:filters] << s
  true
end

$:.unshift(Termtter::CONF_DIR) # still does not use

