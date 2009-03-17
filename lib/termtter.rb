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
require 'optparse'

require 'termtter/config'
require 'termtter/version'
require 'termtter/optparse'
require 'termtter/connection'
require 'termtter/command'
require 'termtter/hook'
require 'termtter/task'
require 'termtter/task_manager'
require 'termtter/client'
require 'termtter/api'
require 'termtter/system_extensions'

module Termtter
  APP_NAME = 'termtter'

  config.system.set_default :conf_dir, File.expand_path('~/.termtter')
  CONF_DIR = config.system.conf_dir

  config.system.set_default :conf_file, CONF_DIR + '/config'
  CONF_FILE = config.system.conf_file
end

if RUBY_VERSION < '1.8.7'
  class Array
    def take(n) self[0...n] end
  end
end

def plugin(name, init = {})
  unless init.empty?
    init.each do |key, value|
      config.plugins.__refer__(name.to_sym).__assign__(key.to_sym, value)
    end
  end
  # FIXME: below path should be replaced by optparsed path
  if File.exist?(path = File.expand_path("~/.termtter/plugins/#{name}"))
    require path
  else
    require "plugins/#{name}"
  end
rescue LoadError => e
  Termtter::Client.handle_error(e)
end

def filter(name, init = {})
  warn "filter method will be removed. Use plugin instead."
  plugin(name, init)
end

$:.unshift(Termtter::CONF_DIR) # still does not use
