module Termtter::Client

  config.update_interval = 3600 * 24 * 365 * 100000

  register_command(:user_stream, :help => 'user_stream [stop]') do |arg|
    args = arg.split /[, ]/
    case args[0]
    when 'stop'
      puts 'stopping user stream'
      if @user_stream_thread
        @user_stream_thread.exit
      end
      @user_stream_thread = nil
    else
      execute('user_stream stop') if @user_stream_thread
      puts 'starting user stream'
      @user_stream_thread = Thread.new {
        loop do
          begin
            uri = URI.parse('http://chirpstream.twitter.com/2b/user.json')
            puts 'connecting to user stream'
            Net::HTTP.start(uri.host, uri.port) do |http|
              request = Net::HTTP::Get.new(uri.request_uri)
              request.basic_auth(config.user_name, config.password)
              http.request(request) do |response|
                raise 'Response is not chuncked' unless response.chunked?
                response.read_body do |chunk|
                  received = Termtter::ActiveRubytter.new(JSON.parse(chunk)) rescue next
                  begin
                    if received[:event]
                      if received[:target_object]
                        # target_object is status
                        source_user = Termtter::API.twitter.user(received.source.id)
                        status = Termtter::API.twitter.show(received.target_object.id)
                        puts "#{source_user.screen_name} #{received.event} #{status.user.screen_name}: #{status.text}"
                      else
                        # target is user
                        source_user = Termtter::API.twitter.user(received.source.id)
                        target_user = Termtter::API.twitter.user(received.target.id)
                        puts "#{source_user.screen_name} #{received.event} #{target_user.screen_name}"
                      end
                    elsif received[:friends]
                      puts "You have #{received[:friends].length} friends."
                    elsif received[:delete]
                      status = Termtter::API.twitter.show(received.delete.status.id)
                      puts "#{status.user.screen_name} deleted: #{status.text}"
                    else
                      output([received], Termtter::Event.new(:update_friends_timeline))
                    end
                  rescue => e
                    handle_error e
                  end
                end
              end
            end
          rescue => e
            handle_error e
            sleep 1
          end
        end
      }
    end
  end

  register_hook(
    :name => :user_stream_init,
    :point => :initialize,
    :exec => lambda {
      execute('user_stream')
    })
end
