# -*- coding: utf-8 -*-

require 'zlib'

config.plugins.history.
  set_default(:filename, '~/.termtter_history')
config.plugins.history.
  set_default(:keys, [:log, :users, :status_ids])
config.plugins.history.
  set_default(:max_of_history, 100)
config.plugins.history.
  set_default(:enable_autosave, true)
config.plugins.history.
  set_default(:autosave_interval, 3600)

module Termtter::Client
  def self.load_history
    filename = File.expand_path(config.plugins.history.filename)
    keys = config.plugins.history.keys

    if File.exist?(filename)
      begin
        history = Marshal.load Zlib::Inflate.inflate(File.read(filename))
      end
      if history
        keys.each do |key|
          public_storage[key] = history[key] if history[key]
        end
        Readline::HISTORY.push *history[:history] if history[:history]
        puts "history loaded(#{File.size(filename)/1000}kb)"
      end
    end
  end

  def self.save_history
    filename = File.expand_path(config.plugins.history.filename)
    keys = config.plugins.history.keys
    history = { }
    keys.each do |key|
      history[key] = public_storage[key]
    end
    max_of_history = config.plugins.history.max_of_history
    history[:history] = Readline::HISTORY.to_a.reverse.uniq.reverse
    if history[:history].size > max_of_history
      history[:history] = history[:history][-max_of_history..-1]
    end

    File.open(filename, 'w') do |f|
      f.write Zlib::Deflate.deflate(Marshal.dump(history))
    end
    puts "history saved(#{File.size(filename)/1000}kb)"
  end

  add_hook do |statuses, event|
    case event
    when :initialize
      load_history
    when :exit
      save_history
    end
  end

  if config.plugins.history.enable_autosave
    Termtter::Client.add_task(:interval => config.plugins.history.autosave_interval,
                              :after => config.plugins.history.autosave_interval) do
      save_history
    end
  end

  register_command(
   :name => :save,
   :exec_proc => lambda{|arg|
     save_history
   },
   :help => ['save', 'Save hisory']
   )

  
end

# history.rb
#   save log to file
