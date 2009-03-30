# -*- coding: utf-8 -*-

require 'erb'
require 'set'

config.plugins.standard.set_default(
 :limit_format,
 '<<%=remaining_color%>><%=limit.remaining_hits%></<%=remaining_color%>>/<%=limit.hourly_limit%> until <%=limit.reset_time%> (<%=remaining_time%> remaining)')

module Termtter::Client

  register_command(
    :name => :update, :aliases => [:u],
    :exec_proc => lambda {|arg|
      unless /^\s*$/ =~ arg
        # TODO: Change to able to disable erb.
        text = ERB.new(arg).result(binding).gsub(/\n/, ' ')
        result = Termtter::API.twitter.update(text)
        puts "=> #{text}"
        result
      end
    },
    :completion_proc => lambda {|cmd, args|
      if /(.*)@([^\s]*)$/ =~ args
        find_user_candidates $2, "#{cmd} #{$1}@%s"
      end
    },
    :help => ["update,u TEXT", "Post a new message"]
  )

  register_command(
    :name => :direct, :aliases => [:d],
    :exec_proc => lambda {|arg|
      if /^([^\s]+)\s+(.*)\s*$/ =~ arg
        user, text = $1, $2
        Termtter::API.twitter.direct_message(user, text)
        puts "=> to:#{user} message:#{text}"
      end
    },
    :completion_proc => lambda {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
    :help => ["direct,d USERNAME TEXT", "Send direct message"]
  )

  register_command(
    :name => :profile, :aliases => [:p],
    :exec_proc => lambda {|arg|
      user = Termtter::API.twitter.user(arg.strip)
      attrs = %w[ name screen_name url description profile_image_url location protected following
        friends_count followers_count statuses_count favourites_count
        id time_zone created_at utc_offset notifications
      ]
      label_width = attrs.map(&:size).max
      attrs.each do |attr|
        value = user.__send__(attr.to_sym)
        puts "#{attr.gsub('_', ' ').rjust(label_width)}: #{value}"
      end
    },
    :completion_proc => lambda {|cmd, arg|
      find_user_candidates arg, "#{cmd} %s"
    },
    :help => ["profile,p USERNAME", "Show user's profile"]
  )

  register_command(
    :name => :followers,
    :exec_proc => lambda {|arg|
      user_name = arg.strip
      user_name = config.user_name if user_name.empty?

      followers = []
      page = 0
      begin
        followers += tmp = Termtter::API.twitter.followers(user_name, :page => page+=1)
      end until tmp.empty?
      Termtter::Client.public_storage[:followers] = followers
      public_storage[:users] += followers.map(&:screen_name)
      puts followers.map(&:screen_name).join(' ')
    },
    :completion_proc => lambda {|cmd, arg|
      find_user_candidates arg, "#{cmd} %s"
    },
    :help => ["followers", "Show followers"]
  )

  register_command(
    :name => :list, :aliases => [:l],
    :exec_proc => lambda {|arg|
      if arg.empty?
        event = :list_friends_timeline
        statuses = Termtter::API.twitter.friends_timeline
      else
        event = :list_user_timeline
        statuses = Termtter::API.twitter.user_timeline(arg)
      end
      output(statuses, event)
    },
    :completion_proc => lambda {|cmd, arg|
      find_user_candidates arg, "#{cmd} %s"
    },
    :help => ["list,l [USERNAME]", "List the posts"]
  )

  public_storage[:search_keywords] = Set.new
  register_command(
    :name => :search, :aliases => [:s],
    :exec_proc => lambda {|arg|
      statuses = Termtter::API.twitter.search(arg)
      public_storage[:search_keywords] << arg
      output(statuses, :search)
    },
    :completion_proc => lambda {|cmd, arg|
      public_storage[:search_keywords].grep(/#{Regexp.quote(arg)}/).map { |i| "#{cmd} #{i}" }
    },
    :help => ["search,s TEXT", "Search for Twitter"]
  )

  register_command(
    :name => :replies, :aliases => [:r],
    :exec_proc => lambda {|arg|
      output(Termtter::API.twitter.replies, :replies)
    },
    :help => ["replies,r", "List the most recent @replies for the authenticating user"]
  )

  register_command(
    :name => :show,
    :exec_proc => lambda {|arg|
      id = arg.gsub(/.*:\s*/, '')
      output([Termtter::API.twitter.show(id)], :show)
    },
    :completion_proc => lambda {|cmd, arg|
      case arg
      when /(\w+):\s*(\d+)\s*$/
        find_status_ids($2).map{|id| "#{cmd} #{$1}: #{id}"}
      else
        users = find_users(arg)
        unless users.empty?
          users.map {|user| "#{cmd} #{user}:"}
        else
          find_status_ids(arg).map {|id| "#{cmd} #{id}"}
        end
      end
    },
    :help => ["show ID", "Show a single status"]
  )

  register_command(
    :name => :shows,
    :exec_proc => lambda {|arg|
      id = arg.gsub(/.*:\s*/, '')
      # TODO: Implement
      #output([Termtter::API.twitter.show(id)], :show)
      puts "Not implemented yet."
    },
    :completion_proc => get_command(:show).completion_proc
  )

  register_command(
    :name => :follow, :aliases => [],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        if /^(\w+)/ =~ arg
          res = Termtter::API::twitter.follow($1.strip)
        end
      end
    },
    :completion_proc => lambda {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
    :help => ['follow USER', 'Follow user']
  )

  register_command(
    :name => :leave, :aliases => [],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        if /^(\w+)/ =~ arg
          res = Termtter::API::twitter.leave($1.strip)
        end
      end
    },
    :completion_proc => lambda {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
    :help => ['leave USER', 'Leave user']
  )

  register_command(
    :name => :favorite, :aliases => [:fav],
    :exec_proc => lambda {|arg|
      id = 0
      case arg
      when /^\d+/
        id = arg.to_i
      when /^@([A-Za-z0-9_]+)/
        user = $1
        statuses = Termtter::API.twitter.user_timeline(user)
        return if statuses.empty?
        id = statuses[0].id
      when /^\/(.*)$/
        word = $1
        raise "Not implemented yet."
      else
        return
      end

      r = Termtter::API.twitter.favorite id
      puts "Favorited status ##{r.id} on user @#{r.user.screen_name} #{r.text}"
    },
    :completion_proc => lambda {|cmd, arg|
      case arg
      when /@(.*)/
        find_user_candidates $1, "#{cmd} @%s"
      when /(\d+)/
        find_status_ids(arg).map{|id| "#{cmd} #{$1}"}
      else
        %w(favorite).grep(/^#{Regexp.quote arg}/)
      end
    },
    :help => ['favorite,fav (ID|@USER|/WORD)', 'Favorite a status']
  )

  # TODO: Change colors when remaining_hits is low.
  # TODO: Simmulate remaining_hits.
  register_command(
    :name => :limit, :aliases => [:lm],
    :exec_proc => lambda {|arg|
      limit = Termtter::API.twitter.limit_status
      remaining_time = "%dmin %dsec" % (Time.parse(limit.reset_time) - Time.now).divmod(60)
      remaining_color =
        case limit.remaining_hits / limit.hourly_limit.to_f
        when 0.2..0.4 then :yellow
        when 0..0.2   then :red
        else               :green
        end
      erbed_text = ERB.new(config.plugins.standard.limit_format).result(binding)
      puts TermColor.parse(erbed_text)
    },
    :help => ["limit,lm", "Show the API limit status"]
  )

  register_command(
    :name => :pause,
    :exec_proc => lambda {|arg| pause},
    :help => ["pause", "Pause updating"]
  )

  register_command(
    :name => :resume,
    :exec_proc => lambda {|arg| resume},
    :help => ["resume", "Resume updating"]
  )

  register_command(
    :name => :exit, :aliases => [:e],
    :exec_proc => lambda {|arg| exit},
    :help => ['exit,e', 'Exit']
  )

  register_command(
    :name => :help, :aliases => [:h],
    :exec_proc => lambda {|arg|
      helps = @commands.map { |name, command| command.help }
      helps.compact!
      puts formatted_help(helps)
    },
    :help => ["help,h", "Print this help message"]
  )

  def self.formatted_help(helps)
    helps = helps.sort_by {|help| help[0] }
    width = helps.map {|n, _| n.size }.max
    space = 3
    helps.map {|name, desc|
      name.to_s.ljust(width + space) + desc.to_s
    }.join("\n")
  end

  # completion for standard commands

  public_storage[:users] ||= Set.new
  public_storage[:status_ids] ||= Set.new

  register_hook(
    :name => :for_completion,
    :points => [:pre_filter],
    :exec_proc => lambda {|statuses, event|
      statuses.each do |s|
        public_storage[:users].add(s.user.screen_name)
        public_storage[:users] += s.text.scan(/@([a-zA-Z_0-9]*)/).flatten
        public_storage[:status_ids].add(s.id)
        public_storage[:status_ids].add(s.in_reply_to_status_id) if s.in_reply_to_status_id
      end
    }
  )

  public_storage[:plugins] = (Dir["#{File.dirname(__FILE__)}/*.rb"] + Dir["#{Termtter::CONF_DIR}/plugins/*.rb"]).map do |f|
    f.match(%r|([^/]+).rb$|)[1]
  end

  register_command(
    :name      => :plugin,
    :exec_proc => lambda {|arg|
      if arg.empty?
        puts 'Should specify plugin name.'
        return
      end
      begin
        result = plugin arg
      rescue LoadError
      ensure
        puts "=> #{result.inspect}"
      end
    },
    :completion_proc => lambda {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
      unless args.empty?
        find_plugin_candidates args, "#{cmd} %s"
      else
        public_storage[:plugins].sort
      end
    },
    :help      => ['plugin FILE', 'Load a plugin']
  )

  register_command(
    :name      => :plugins,
    :exec_proc => lambda {|arg|
      puts public_storage[:plugins].sort.join("\n")
    },
    :help      => ['plugins', 'Show list of plugins']
  )

  register_command(
    :name => :reply,
    :aliases => [:re],
    :exec_proc => lambda {|arg|
      case arg
      when /^\s*(?:list)?\s*$/
        public_storage[:log4re] = public_storage[:log].sort {|a,b| a.id <=> b.id}
        public_storage[:log4re].each_with_index do |s, i|
          puts "#{i}: #{s.user.screen_name}: #{s.text}"
        end
      when /^\s*(\d+)\s+(.+)$/
        id   = public_storage[:log4re][$1.to_i].id
        user = public_storage[:log4re][$1.to_i].user.screen_name
        text = ERB.new("@#{user} #{$2}").result(binding).gsub(/\n/, ' ')
        result = Termtter::API.twitter.update(text, {'in_reply_to_status_id' => id})
        puts "=> #{text}"
        public_storage.delete :log4re
        result
      end
    },
    :completion_proc => lambda {|cmd, args|
      #todo
    }
  )
=begin
  = Termtter reply command
  == Usage
  === list
  * ステータスのリストを連番と一緒に出す。
   command: reply [list]
   > reply
   0: foo: foo's message
   1: bar: bar's message
   ..

  === reply
  * 上記listコマンドで出したステータスNOに対してメッセージを送る。
  * メッセージ送信の際、@usernameが自動的に付与される。
   command: reply [u|update] status_no message
   > reply u 0 message4foo

  == Todo
  * 英語で説明 => ヘルプを設定する
  * リファクタ
  * 補完
  * 「reply @user_name メッセージ」 として直近のメッセージに reply できたらよいかも
  * 確認画面を出したい
=end

  def self.find_plugin_candidates(a, b)
    public_storage[:plugins].
      grep(/^#{Regexp.quote a}/i).
      map {|u| b % u }
  end

  def self.find_status_ids(text)
    public_storage[:status_ids].select {|id| /#{Regexp.quote(text)}/ =~ id.to_s}
  end

  def self.find_users(text)
    public_storage[:users].select {|user| /#{Regexp.quote(text)}/ =~ user}
  end

  def self.find_user_candidates(a, b)
    users = 
      if a.nil? || a.empty?
        public_storage[:users].to_a
      else
        public_storage[:users].grep(/^#{Regexp.quote a}/i)
      end
    users.map {|u| b % u }
  end
end
