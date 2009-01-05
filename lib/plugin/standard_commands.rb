module Termtter::Client

  add_command /^(update|u)\s+(.*)/ do |m, t|
    text = m[2]
    unless text.empty?
      t.update_status(text)
      puts "=> #{text}"
    end
  end

  add_command /^(list|l)\s*$/ do |m, t|
    statuses = t.get_friends_timeline()
    call_hooks(statuses, :list_friends_timeline, t)
  end

  add_command /^(list|l)\s+([^\s]+)/ do |m, t|
    statuses = t.get_user_timeline(m[2])
    call_hooks(statuses, :list_user_timeline, t)
  end

  add_command /^(search|s)\s+(.+)/ do |m, t|
    call_hooks(t.search(m[2]), :search, t)
  end

  add_command /^(replies|r)\s*$/ do |m, t|
    call_hooks(t.replies(), :replies, t)
  end

  add_command /^show\s+([^\s]+)/ do |m, t|
    call_hooks(t.show(m[1]), :show, t)
  end

  add_command /^pause\s*$/ do |m, t|
    pause
  end

  add_command /^resume\s*$/ do |m, t|
    resume
  end

  add_command /^exit\s*$/ do |m, t|
    exit
  end

  add_command /^help\s*$/ do |m, t|
    puts <<-EOS
exit              Exit
help              Print this help message
list,l            List the posts in your friends timeline
list,l USERNAME   List the posts in the the given user's timeline
pause             Pause updating
update,u TEXT     Post a new message
resume            Resume updating
replies,r         List the most recent @replies for the authenticating user
search,s TEXT     Search for Twitter
show ID           Show a single status
    EOS
  end

  add_command /^eval\s+(.*)$/ do |m, t|
    begin
      result = eval(m[1]) unless m[1].empty?
      puts "=> #{result.inspect}"
    rescue SyntaxError => e
      puts e
    end
  end

end
