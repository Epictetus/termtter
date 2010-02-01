# -*- coding: utf-8 -*-
require 'set'

config.plugins.keyword.set_default(
  :highlight_patterns,
  [
    ['on_cyan', 'white'],
    ['on_green', 'white'],
    ['on_magenta', 'white'],
    ['on_red', 'white'],
    ['on_blue', 'white'],
    ['on_black', 'white'],
    ['on_white', 'white'],
    ['on_yellow', 'white'],
  ]
)

config.plugins.keyword.set_default(:keywords, [])

module Termtter::Client
  public_storage[:keywords] ||= Set.new(config.plugins.keyword.keywords)

  register_hook :highlight_keywords, :point => :pre_coloring do |text, event|
    public_storage[:keywords].each_with_index do |keyword, index|
      highlight_pattern = config.plugins.keyword.highlight_patterns[index % config.plugins.keyword.highlight_patterns.size]
      text = text.gsub(
                /(#{Regexp.quote(keyword)})/i,
                "<#{highlight_pattern[0]}><#{highlight_pattern[1]}>" +
                "\\1" +
                "</#{highlight_pattern[1]}></#{highlight_pattern[0]}>"
              )
    end
    text
  end

  register_hook :notify_for_keywords, :point => :output do |statuses, event|
    if event == :update_friends_timeline
      statuses.select { |status|
        /#{Regexp.union(public_storage[:keywords].map(&:to_s))}/ =~ status.text
      }.each do |status|
        notify(status.user.screen_name, status.text)
      end
    end
  end

  register_command(
    'keyword add',
    :help => ['keyword add KEYWORD', 'Add a highlight keyword']
  ) do |args|
    args.split(/\s+/).each do |arg|
      public_storage[:keywords] << arg
    end
  end

  register_command(
    'keyword clear',
    :help => ['keyword clear', 'Clear highlight keywords']
  ) do |args|
    public_storage[:keywords].clear
  end

  register_command(
    'keyword list',
    :help => ['keyword list', 'List highlight keywords']
  ) do |args|
    p public_storage[:keywords].to_a
  end
end
