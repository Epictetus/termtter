module Termtter
  class Command

    attr_accessor :names, :exec_proc, :completion_proc, :help, :pattern

    # args
    #   names:      String or Array (ex. ['update', 'u'])
    #   exec:       Proc for procedure of the command. If need the proc must return object for hook.
    #   completion: Proc for input completion. The proc must return Array of candidates (Optional)
    #   help:       help text for the command (Optional)
    def initialize(args)
      @names = [args[:names]].flatten
      @exec_proc = args[:exec]
      @completion_proc = args[:completion]
      @help = args[:help]
    end

    def complement(input)
      completion_proc.call(input)
    end

    # MEMO: Termtter:Client からはこのメソッドを呼び出すことになるとお思う。
    # MEMO: ArgumentError が発生したときは呼び出し元で Command#help を表示するなどしてほしい
    def exec_if_match(input)
      if input =~ pattern
        execute($2)
      end
    end

    def execute(arg)
      exec_proc.call(arg)
    end

    def pattern
      /^(#{names.map{|i|Regexp.quote(i)}.join('|')})\s*(.*)/
    end
  end
end

