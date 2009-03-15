# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

describe Termtter, 'when plugin is called' do
  it 'should require global plugin if exist' do
    File.should_receive(:exist?).and_return(false)
    should_receive(:require).with('plugins/aaa')
    plugin 'aaa'
  end

  it 'should require user plugin if not exist' do
    File.should_receive(:exist?).and_return(true)
    should_receive(:require).with(File.expand_path('~/.termtter/plugins/aaa'))
    plugin 'aaa'
  end

  it 'should handle_error if there are no plugins in global or user' do
    Termtter::Client.should_receive(:handle_error)
    plugin 'not-exist-plugin-hehehehehehe'
  end
end
