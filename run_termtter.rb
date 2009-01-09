#!/usr/bin/env ruby

$KCODE = 'u'

self_file =
  if File.ftype(__FILE__) == 'link'
    File.readlink(__FILE__)
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

require 'termtter'
plugin 'standard_plugins'
plugin 'stdout'

conf_file = File.expand_path('~/.termtter')
if File.exist? conf_file
  load conf_file
else
  HighLine.track_eof = false
  ui = HighLine.new
  username = ui.ask('your twitter username: ')
  password = ui.ask('your twitter password: ') { |q| q.echo = false }

  File.open(File.expand_path('~/.termtter'), 'w') {|io|
    plugins = Dir.glob(File.dirname(__FILE__) + "/../lib/plugin/*.rb").map  {|f|
      f.match(%r|lib/plugin/(.*?).rb$|)[1]
    }
    plugins -= %w[stdout standard_plugins]
    plugins.each do |p|
      io.puts "#plugin '#{p}'"
    end

    io.puts
    io.puts "configatron.user_name = '#{username}'"
    io.puts "configatron.password = '#{password}'"
    io.puts "#configatron.update_interval = 120"
    io.puts "#configatron.proxy.host = 'proxy host'"
    io.puts "#configatron.proxy.port = '8080'"
    io.puts "#configatron.proxy.user_name = 'proxy user'"
    io.puts "#configatron.proxy.password = 'proxy password'"
    io.puts
    io.puts "# vim: set filetype=ruby"
  }
  puts "generated: ~/.termtter"
  puts "enjoy!"
  load conf_file
end

Termtter::Client.run

# Startup scripts for development
