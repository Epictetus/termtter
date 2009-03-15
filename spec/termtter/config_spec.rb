# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe Config do
    before do
      @config = Config.new
    end

    it 'should be able to store value to new storage' do
      @config.new_storage = :value
      @config.new_storage.should == :value
    end

    it 'should be able to make subb.key and store value' do
      @config.subb.key = :value
      @config.subb.key.should == :value
    end

    it 'should be able to make multiple storage' do
      @config.subb.more.for.test = 'value'
      @config.subb.more.for.test.should == 'value'
    end

    it 'should be able to change value in storage' do
      @config.storage = :value1
      @config.storage = :value2
      @config.storage.should == :value2
    end

    it 'should be able to store any data' do
      [
        ['string',  'value'   ],
        ['symbol',  :value    ],
        ['arrry',   [:a, :b]  ],
        ['hashes',    {:a => :b}],
        ['integer', 1         ],
        ['float',   1.5       ],
        ['regexp',  /regexp/  ],
      ].each do |type, value|
        @config.__send__("#{type}=", value)
        @config.__send__(type).should == value
      end
    end

    it 'should raise error when add subb-storage to existed key' do
      @config.subb = 'original value'
      lambda {
        @config.subb.key = 'invalid subbstitution'
      }.should raise_error(
        NoMethodError,
        %r[undefined method `key=' for "original value":String]
      )
    end

    it 'should set intermediate defult configs' do
      @config.set_default 'subb.more', 'value'
      @config.subb.class.should == Config
      @config.subb.more.should == 'value'

      @config.proxy.set_default(:port, 'value')
      @config.proxy.port.should == 'value'
    end

    # FIXME: not work
#     it 'should have :undefined value in un-assigned key' do
#       @config.aaaa.should == :undefined
#     end

    it 'should be empty when something is assigned' do
      @config.empty?.should be_true

      @config.aaa = 1
      @config.empty?.should be_false

      @config.bbb.empty?.should be_true
    end

    it 'should be empty when assigned nil' do
      @config.bbb = nil
      @config.empty?.should be_false
    end

    it 'should be empty when set_defaulted' do
      @config.set_default('aaa', 1)
      @config.empty?.should be_false
    end

    it 'should use in expression' do
      @config.set_default(:ssb, 'hoge')
      lambda {
        res = @config.ssb + ' piyo'
        res.should == 'hoge piyo'
      }.should_not raise_error
    end
  end
end
