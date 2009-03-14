# -*- coding: utf-8 -*-

module Termtter::Client
  register_command :name => :shell, :aliases => [:sh],
    :help => ['shell,sh', 'Start your shell'],
    :exec_proc => lambda {|args|
      begin
        pause
        system ENV['SHELL'] || ENV['COMSPEC']
      ensure
        resume
      end
    }
end
