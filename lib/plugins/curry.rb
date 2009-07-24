# -*- coding: utf-8 -*-

module Termtter::Client
  public_storage[:curry] = ''

  register_command(
    :name => :curry,
    :aliases => [:<],
    :exec_proc => lambda {|arg|
      public_storage[:curry] = arg + ' '
    }
  )

  register_command(
    :name => :uncurry,
    :aliases => [:>],
    :exec_proc => lambda {|arg|
      public_storage[:curry] = ''
    }
  )

  register_hook(
    :name => :curry_pre,
    :point => :pre_command,
    :exec => lambda {|text|
      /^(uncurry|<)$/ =~ text ? text : public_storage[:curry] + text
    }
  )

  register_hook(
    :name => :curry_post,
    :point => :post_command,
    :exec => lambda {|_| print public_storage[:curry] }
  )
end
