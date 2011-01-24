require 'user-stream-receiver'

module Termtter::Client
  register_command(:"user_stream stop", :help => 'user_stream stop') do |arg|
    logger.info 'stopping user stream'
    if @user_stream_thread
      @user_stream_thread.exit
    end
    @user_stream_thread = nil
    plug "defaults/auto_reload"
  end

  handle_chunk = lambda { |chunk|
    data = Termtter::ActiveRubytter.new(JSON.parse(chunk)) rescue return
    Termtter::Client.logger.debug "user_stream: received #{JSON.parse(chunk).inspect}"
    print "\e[0G" + "\e[K" unless win?
    begin
      if data[:event]
        if /list_/ =~ data[:event]
          typable_id = Termtter::Client.data_to_typable_id(data.target.id)
          puts "[%s] %s %s %s to %s]" %
            [typable_id, data.source.screen_name, data.event, data.target.screen_name, data.target_object.uri]
          return
        end
        if data[:target_object]
          # target_object is status
          source_user = data.source
          status = data.target_object
          typable_id = Termtter::Client.data_to_typable_id(status.id)
          puts "[#{typable_id}] #{source_user.screen_name} #{data.event} #{status.user.screen_name}: #{status.text}"
        else
          # target is user
          source_user = data.source
          target_user = data.target
          typable_id = Termtter::Client.data_to_typable_id(target_user.id)
          puts "[#{typable_id}] #{source_user.screen_name} #{data.event} #{target_user.screen_name}"
        end
      elsif data[:friends]
        puts "You have #{data[:friends].length} friends."
      elsif data[:delete]
        status = Termtter::API.twitter.safe.show(data.delete.status.id)
        puts "#{status.user.screen_name} deleted: #{status.text}"
      else
        output([data], Termtter::Event.new(:update_friends_timeline, :type => :main))
        Termtter::API.twitter.store_status_cache(data)
      end
    rescue Termtter::RubytterProxy::FrequentAccessError
      # ignore
    rescue Timeout::Error, StandardError => error
      new_error = error.class.new("#{error.message} (#{JSON.parse(chunk).inspect})")
      error.instance_variables.each{ |v|
        new_error.instance_variable_set(v, error.instance_variable_get(v))
      }
      handle_error new_error
    ensure
      Readline.refresh_line
    end
  }

  register_command(:"user_stream", :help => 'user_stream') do |arg|

    execute('user_stream stop') if @user_stream_thread
    delete_task(:auto_reload)

    @user_stream_thread = Thread.new {
      UserStreamReceiver.new_from_access_token(Termtter::API.twitter.access_token).run{|chunk|
        call_hooks(:user_stream_receive, chunk)
      }
    }
  end

  register_hook(
    :name => :user_stream_init,
    :point => :initialize,
    :exec => lambda {
      execute('user_stream')
    })

  register_hook(
    :name => :user_stream_print,
    :point => :user_stream_receive,
    :exec => lambda {|chunk|
      handle_chunk.call(chunk)
    })

end

# user_stream.rb
#
# to use,
#   > plug user_stream
#   > user_stream
#
# to stop,
#   > user_stream stop
#
# Specification
#   http://apiwiki.twitter.com/ChirpUserStreams
