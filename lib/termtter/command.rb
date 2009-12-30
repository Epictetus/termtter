# -*- coding: utf-8 -*-

module Termtter
  class Command
    attr_accessor :name, :aliases, :exec_proc, :completion_proc, :help

    # args
    #   name:            (required) Symbol as command name
    #   aliases:         Array of command alias (ex. ['u', 'up'])
    #   exec_proc:       Proc for procedure of the command. If need the proc must return object for hook.
    #   completion_proc: Proc for input completion. The proc must return Array of candidates (Optional)
    #   help:            help text for the command (Optional)
    def initialize(args)
      raise ArgumentError, ":name is not given." unless args.has_key?(:name)
      args = args.dup
      args[:exec_proc] ||= args[:exec]
      args[:completion_proc] ||= args[:completion]
      args[:aliases] ||= [args[:alias]].compact

      cfg = {
        :aliases        => [],
        :exec_proc      => lambda {|arg| },
        :comletion_proc => lambda {|command, arg| [] }
      }.merge(args)

      set cfg
    end

    # set :: Hash -> ()
    def set(cfg)
      self.name             = cfg[:name].to_sym
      self.aliases          = cfg[:aliases]
      self.exec_proc        = cfg[:exec_proc]
      self.completion_proc  = cfg[:completion_proc]
      self.help             = cfg[:help]
    end

    # complement :: String -> [String]
    def complement(input)
      if match?(input) && input =~ /^[^\s]+\s/
        if completion_proc
          command_str, command_arg = split_command_line(input)
          [completion_proc.call(command_str, command_arg || '')].flatten.compact
        else
          []
        end
      else
        ([name.to_s] + aliases.map(&:to_s)).grep(/^#{Regexp.quote(input)}/)
      end
    end

    # call :: ???
    def call(cmd = nil, arg = nil, original_text = nil)
      arg = case arg
        when nil
          ''
        when String
          arg
        else
          raise ArgumentError, 'arg should be String or nil'
        end
      exec_proc.call(arg)
    end

    # match? :: String -> Boolean
    def match?(input)
      pattern === input
    end

    # pattern :: Regexp
    def pattern
      commands_regex = commands.map {|name| Regexp.quote(name.to_s) }.join('|')
      /^((#{commands_regex})|(#{commands_regex})\s+(.*?))\s*$/
    end

    # commands :: [Symbol]
    def commands
      [name] + aliases
    end

    def aliases=(as)
      @aliases = as.map { |a| a.to_sym }
    end

    # alias= :: Symbol -> ()
    def alias=(a)
      self.aliases = [a]
    end

    def command_words
      name.to_s.split(/\s+/)
    end

    # split_command_line :: String -> (String, String)
    def split_command_line(line)
      command_words_count = command_words.size
      parts = line.strip.split(/\s+/, command_words_count + 1)
      [parts[0...command_words_count].join(' '), parts[command_words_count] || '']
    end
  end
end
