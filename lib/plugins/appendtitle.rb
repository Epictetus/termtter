# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'timeout'
require "memcache"

module Termtter::Client
  config.plugins.appendtitle.set_default(:timeout, 30)
  config.plugins.appendtitle.set_default(:cache_expire, 3600 * 24 * 7)
  config.plugins.appendtitle.set_default(:memcached_server, 'localhost:11211')

  def self.fetch_title(uri)
    return unless uri
    cache = MemCache.new(config.plugins.appendtitle.memcached_server)
    key = %w{ termtter plugins appendtitle title}.push(uri).join('-')
    if v = cache.get(key)
      logger.debug "appendtitle: cache hit for #{uri}"
      return v
    end

    cache.set(key, '', config.plugins.appendtitle.cache_expire) # to avoid duplicate fetch
    begin
      logger.debug "appendtitle: fetching title for #{uri}"
      source = Nokogiri(open(uri).read)
      if source and source.at('title')
        title = source.at('title').text.gsub(/\n/, '').gsub(/\s+/, ' ')
        cache.set(key, title, config.plugins.appendtitle.cache_expire)
        return title
      end
      nil
     rescue Timeout::Error
      nil
     rescue
      nil
    end
  end

  register_hook(
    :name => :appendtitle,
    :point => :filter_for_output,
    :exec_proc => lambda do |statuses, event|
      threads = statuses.map do |status|
        Thread.new{
          status.text.gsub!(URI.regexp(['http', 'https'])) {|uri|
            title = fetch_title(uri)
            if title and not (
                status.text.include? title or
                status.text.include? title[0..(title.length/2)] or
                status.text.include? title[(title.length/2)..-1]) # XXX: heuristic!!!
              "#{uri} (#{title})"
            else
              uri
            end
          }
        }
      end
      begin
        # wait for join or timeout
        timeout(config.plugins.appendtitle.timeout) {
          threads.each{ |t| t.join }
        }
      rescue Timeout::Error
        logger.error 'appendtitle: timeout'
      end

      statuses
    end
    )
end

# appendtitle.rb:
# append title for uri.
