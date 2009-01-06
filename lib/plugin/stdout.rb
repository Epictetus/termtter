require 'erb'

configatron.set_default(:timeline_format, '<%= color(time, 90) %> <%= status %> <%= color(id, 90) %>')

def color(str, num)
  "\e[#{num}m#{str}\e[0m"
end

Termtter::Client.add_hook do |statuses, event|
  colors = %w(0 31 32 33 34 35 36 91 92 93 94 95 96)

  case event
  when :update_friends_timeline, :list_friends_timeline, :list_user_timeline, :show, :replies
    unless statuses.empty?
      if event == :update_friends_timeline then statuses = statuses.reverse end
      statuses.each do |s|
        text = s.text.gsub("\n", '')
        color_num = colors[s.user_screen_name.hash % colors.size]
        status = "#{s.user_screen_name}: #{text}"
        if s.in_reply_to_status_id
          status += " (reply to #{s.in_reply_to_status_id})"
        end

        case event
        when :update_friends_timeline, :list_friends_timeline
          time_format = '%H:%M:%S'
        else
          time_format = '%m-%d %H:%M'
        end

        time = "(#{s.created_at.strftime(time_format)})"
        status = color(status, color_num)
        id = s.id
        puts ERB.new(configatron.timeline_format).result(binding)
      end
    end
  when :search
    statuses.each do |s|
      text = s.text.gsub("\n", '')
      color_num = colors[s.user_screen_name.hash % colors.size]

      status = color("#{s.user_screen_name}: #{text}", color_num)
      time = "(#{s.created_at.strftime('%m-%d %H:%M')})"
      id = s.id
      puts ERB.new(configatron.timeline_format).result(binding)
    end
  end
end
