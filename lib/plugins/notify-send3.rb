# -*- coding: utf-8 -*-
require 'fileutils'
require 'RMagick'
require 'uri'

# Copy from notify-send2.rb
config.plugins.notify_send.set_default(
  :icon_cache_dir, "#{Termtter::CONF_DIR}/tmp/user_profile_images")
def get_icon_path(s)
  FileUtils.mkdir_p(config.plugins.notify_send.icon_cache_dir) unless
    File.exist?(config.plugins.notify_send.icon_cache_dir)
  cache_file = "%s/%s%s" % [
    config.plugins.notify_send.icon_cache_dir,
    s.user.screen_name,
    File.extname(s.user.profile_image_url)]
  if !File.exist?(cache_file) ||
    (File.atime(cache_file) + 24*60*60) < Time.now
    File.open(cache_file, "wb") do |f|
      begin
        http_class = Net::HTTP
        unless config.proxy.host.nil? or config.proxy.host.empty?
          http_class = Net::HTTP::Proxy(
            config.proxy.host,
            config.proxy.port,
            config.proxy.user_name,
            config.proxy.password)
        end
        uri = URI.parse(URI.escape(s.user.profile_image_url))
        image = http_class.get(uri.host, uri.path, uri.port)
        rimage = Magick::Image.from_blob(image).first
        rimage = rimage.resize_to_fill(48, 48)
        f << rimage.to_blob
      rescue Net::ProtocolError, Magick::ImageMagickError
        return nil
      end
    end
  end
  cache_file
end

Termtter::Client.register_hook(
  :name => :notify_send3,
  :points => [:output],
  :exec_proc => lambda {|statuses, event|
    return unless event == :update_friends_timeline
    Thread.start do
      statuses.each do |s|
        text = CGI.escapeHTML(s.text)
        text = %Q{"#{text}"} if text =~ /^-/
        text.gsub!(URI.regexp,'<a href="\0">\0</a>')
        begin
          system 'notify-send', '-i', get_icon_path(s), '--', s.user.screen_name, text
          sleep 0.05
        rescue
        end
      end
    end
  }
)
# notify-send3.rb
#   caching resized profile image.
