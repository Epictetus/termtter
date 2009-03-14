# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter

  describe Command do

    before do
      params =  {
          :name            => 'update',
          :aliases         => ['u', 'up'],
          :exec_proc       => lambda {|arg| arg },
          :completion_proc => lambda {|command, arg| ['complete1', 'complete2'] },
          :help            => ['update,u TEXT', 'test command']
      }
      @command = Command.new(params)
    end

    it 'should return command regex' do
      @command.pattern.should == /^((update|u|up)|(update|u|up)\s+(.*?))\s*$/
    end

    it 'should be given name as String or Symbol' do
      Command.new(:name => 'foo').name.should == :foo
      Command.new(:name => :foo).name.should == :foo
    end

    it 'should return name' do
      @command.name.should == :update
    end

    it 'should return aliases' do
      @command.aliases.should == [:u, :up]
    end

    it 'should return commands' do
      @command.commands.should == [:update, :u, :up]
    end

    it 'should return help' do
      @command.help.should == ['update,u TEXT', 'test command']
    end

    it 'should return candidates for completion' do
      # complement
      [
        ['upd',       ['update']],
        [' upd',      []],
        [' upd ',     []],
        ['update',    ['complete1', 'complete2']],
        ['update ',   ['complete1', 'complete2']],
        [' update  ', []],
        ['u foo',     ['complete1', 'complete2']],
        ['u',         ['complete1', 'complete2']],
        ['up',        ['complete1', 'complete2']],
      ].each do |input, comp|
        @command.complement(input).should == comp
      end
    end

    it 'should return command_info when call method "match?"' do
      [
        ['update',       ['update', nil]],
        ['up',           ['up', nil]],
        ['u',            ['u', nil]],
        ['update ',      ['update', nil]],
        [' update ',     [nil, nil]],
        ['update foo',   ['update', 'foo']],
        [' update foo',  [nil, nil]],
        [' update foo ', [nil, nil]],
        ['u foo',        ['u', 'foo']],
        ['up foo',       ['up', 'foo']],
        ['upd foo',      [nil, nil]],
        ['upd foo',      [nil, nil]],
      ].each do |input, result|
        @command.match?(input).should == result
      end
    end

    it 'should raise ArgumentError when constructor arguments are deficient' do
      lambda { Command.new }.should raise_error(ArgumentError)
      lambda { Command.new(:exec_proc => lambda {|args|}) }.should raise_error(ArgumentError)
      lambda { Command.new(:aliases => ['u']) }.should raise_error(ArgumentError)
    end

    it 'should call exec_proc when call method "execute"' do
      @command.execute('test').should == 'test'
      @command.execute(' test').should == ' test'
      @command.execute(' test ').should == ' test '
      @command.execute('test test').should == 'test test'
    end

    it 'should raise ArgumentError at execute' do
      lambda { @command.execute(nil) }.should_not raise_error(ArgumentError)
      lambda { @command.execute('foo') }.should_not raise_error(ArgumentError)
      lambda { @command.execute(false) }.should raise_error(ArgumentError)
      lambda { @command.execute(Array.new) }.should raise_error(ArgumentError)
    end
  end
end

