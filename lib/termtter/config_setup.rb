# -*- coding: utf-8 -*-

module Termtter
  module ConfigSetup
    module_function
    def run
      ui = create_highline
      username = ui.ask('your twitter username: ')
      password = ui.ask('your twitter password: ') { |q| q.echo = false }

      Dir.mkdir(Termtter::CONF_DIR) unless File.exists?(Termtter::CONF_DIR)
      File.open(Termtter::CONF_FILE, 'w') {|io|
        io.puts '# -*- coding: utf-8 -*-'

        io.puts
        io.puts "config.user_name = '#{username}'"
        io.puts "config.password = '#{password}'"
        io.puts "#config.update_interval = 120"
        io.puts "#config.proxy.host = 'proxy host'"
        io.puts "#config.proxy.port = '8080'"
        io.puts "#config.proxy.user_name = 'proxy user'"
        io.puts "#config.proxy.password = 'proxy password'"
        io.puts
        plugins = Dir.glob(File.expand_path(File.dirname(__FILE__) + "/../plugins/*.rb")).map  {|f|
          f.match(%r|lib/plugins/(.*?).rb$|)[1]
        }
        plugins -= %w[stdout standard_plugins]
        plugins.each do |p|
          io.puts "#plugin '#{p}'"
        end
        io.puts
        io.puts "# vim: set filetype=ruby"
      }
      puts "generated: ~/.termtter/config"
      puts "enjoy!"
    end
  end
end
