require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'

class Termtter
  
  @@handlers = []

  def self.add_hook(&handler)
    @@handlers << handler
  end

  def initialize(user_name, password)
    if user_name.nil? || user_name.empty? then raise ArgumentError, "user_name is not set." end
    if password.nil? || password.empty? then raise ArgumentError, "password is not set." end
    @user_name = user_name
    @password = password
  end

  def update_status(status)
    req = Net::HTTP::Post.new('/statuses/update.xml')
    req.basic_auth(@user_name, @password)
    req.add_field("User-Agent", "Termtter http://github.com/jugyo/termtter")
    req.add_field("X-Twitter-Client", "Termtter")
    req.add_field("X-Twitter-Client-URL", "http://github.com/jugyo/termtter")
    req.add_field("X-Twitter-Client-Version", "0.1")
    Net::HTTP.start("twitter.com", 80) do |http|
      http.request(req, "status=#{CGI.escape(status)}")
    end
  end

  def fetch_timeline
    uri = 'http://twitter.com/statuses/friends_timeline.xml'
    if @since_id && !@since_id.empty?
      uri += "?since_id=#{@since_id}"
    end

    begin
      statuses = []
      doc = Nokogiri::XML(open(uri, :http_basic_authentication => [@user_name, @password]))

      new_since_id = doc.xpath('//status[1]/id').text
      @since_id = new_since_id if new_since_id && !new_since_id.empty?

      doc.xpath('//status').each do |s|
        status = {}
        %w(
          id text created_at truncated in_reply_to_status_id in_reply_to_user_id 
          user/id user/name user/screen_name
        ).each do |key|
          status[key] = CGI.unescapeHTML(s.xpath(key).text)
        end
        statuses << status
      end
      
      
      @@handlers.each do |h|
        h.call(statuses)
      end
    rescue => e
      puts "Error: #{e}. request uri => #{uri}"
    end
  end

end
