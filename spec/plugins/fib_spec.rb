# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin fib is loaded' do
  it 'should add command fib' do
    Termtter::Client.should_receive(:register_command).once
    Termtter::Client.plug 'defaults/fib'
  end

  it 'should define fib method' do
    Termtter::Client.plug 'defaults/fib'
    (0..10).map {|i| fib i }.should == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
  end
end
