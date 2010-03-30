#-*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'open-uri'

describe 'plugin tinyurl' do
  before do
    Termtter::Client.setup_task_manager
  end

  it 'adds hook :tinyurl' do
    Termtter::Client.should_receive(:register_hook).once
    Termtter::Client.plug 'tinyurl'
    #Termtter::Client.get_hook(:tinyurl).should be_a_kind_of(Hook)
    #Termtter::Client.get_hook(:tinyurl).name.should == :tinyurl
  end

  it 'truncates url' do
    Termtter::Client.register_command(
      :name => :update, :alias => :u,
      :exec => lambda do |url|
        url.should match(/(bit\.ly|tinyurl|is\.gd)/)
        open(url) do |f|
          f.base_uri.to_s.should match('www.google')
        end
      end
    )
    Termtter::Client.plug 'tinyurl'
    Termtter::Client.execute('update http://www.google.com/')
  end

  it 'truncates url with not escaped Non-ASCII characters' do
    Termtter::Client.register_command(
      :name => :update, :alias => :u,
      :exec => lambda do |url|
        url.should match(/(bit\.ly|tinyurl|is\.gd)/)
        open(url) do |f|
          f.base_uri.to_s.should match('http://ja.wikipedia.org/wiki/%E6%B7%B1%E7%94%B0%E6%81%AD%E5%AD%90')
        end
      end
    )
    Termtter::Client.plug 'tinyurl'
    Termtter::Client.execute('update http://ja.wikipedia.org/wiki/深田恭子')
  end

  it 'truncates url with escaped Non-ASCII characters' do
    Termtter::Client.register_command(
      :name => :update, :alias => :u,
      :exec => lambda do |url|
        url.should match(/(bit\.ly|tinyurl|is\.gd)/)
        open(url) do |f|
          f.base_uri.to_s.should match('http://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%88%E3%83%AA%E3%83%BC%E3%83%88%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0')
        end
      end
    )
    Termtter::Client.plug 'tinyurl'
    Termtter::Client.execute('update http://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%88%E3%83%AA%E3%83%BC%E3%83%88%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0')
  end
end
