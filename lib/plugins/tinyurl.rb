# -*- coding: utf-8 -*-

SHORTURL_MAKERS = [
  { :host => "tinyurl.com", :format => '/api-create.php?url=%s' },
  { :host => "is.gd", :format => '/api.php?longurl=%s' },
  { :host => "to.ly", :format => '/api.php?longurl=%s' },
]
TINYURL_HOOK_COMMANDS = [:update, :reply]
URI_REGEXP = URI.regexp(%w(http https ftp))

Termtter::Client.register_hook(
  :name => :tinyurl,
  :points => TINYURL_HOOK_COMMANDS.map {|cmd|
    "modify_arg_for_#{cmd.to_s}".to_sym
  },
  :exec_proc => lambda {|cmd, arg|
    http_class = Net::HTTP
    unless config.proxy.host.nil? or config.proxy.host.empty?
      http_class = Net::HTTP::Proxy(config.proxy.host,
                                    config.proxy.port,
                                    config.proxy.user_name,
                                    config.proxy.password)
    end
    arg.gsub(URI_REGEXP) do |url|
      url_enc = URI.escape(url)
      result = url
      SHORTURL_MAKERS.each do |site|
        res = http_class.new(site[:host]).get(site[:format] % url_enc)
        if res.code == '200'
          result = res.body
          break
        end
      end
      result
    end
  }
)

# tinyuri.rb
# make URLs in your update to convert tinyurl.com/XXXXXXX.
