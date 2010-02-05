# -*- coding: utf-8 -*-

Termtter::Client.register_hook(
  :name => :notify_send,
  :points => [:output],
  :exec_proc => lambda {|statuses, event|
    if event == :update_friends_timeline
      max = 10

      text = statuses.take(max).map {|s|
        status_text = CGI.escapeHTML(s.text)
        status_text.gsub!(%r{https?://[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+},'<a href="\0">\0</a>')
        "<b>#{s.user.screen_name}:</b> <span font=\"9.0\">#{status_text}</span>"
      }.join("\n")

      text << %Q|\n<a href="http://twitter.com/">more...</a>| if statuses.size > max

      Termtter::Client.notify 'timeline', text unless text.empty?
    end
  }
)

