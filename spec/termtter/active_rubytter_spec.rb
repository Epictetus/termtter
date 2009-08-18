# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'termtter/active_rubytter'

module Termtter
  describe ActiveRubytter do

    it 'Hashをクラス化できる' do
      d = ActiveRubytter.new(:name => 'termtter', :age => 16)
      d.name.should == 'termtter'
      d.age.should == 16
    end

    it '元のHashを得られること' do
      data = { :test => 'test' }
      d = ActiveRubytter.new(data)
      d.to_hash.should == data
    end

    describe '入れ子のHashの処理' do

      before(:all) do
        @data = {
          :hoge => "hogehoge",
          :fuga => "fugafuga",
          :hage => {
            :foo => "foofoo",
            :bar => {
              :nest => "nestnest"
            }
          }
        }
      end

      before(:each) do
        @d = ActiveRubytter.new(@data)
      end

      it "入れ子のHashをクラス化できる" do
        @d.should be_instance_of(ActiveRubytter)

        #array.map{ |elem| ActiveRubytter.new(elem)})}
      end

      it "Hashからクラス化して`.'でアクセスできる" do
        @d.hoge.should == "hogehoge"

        #array.map{ |elem| ActiveRubytter.new(elem)})}
      end

      it "Hashからクラス化して`.'で入れ子でもアクセスできる" do
        @d.hage.foo.should == "foofoo"

        #array.map{ |elem| ActiveRubytter.new(elem)})}
      end

      it "Hashからクラス化して`.'で入れ子の入れ子でもアクセスできる" do
        @d.hage.bar.nest.should == "nestnest"

        #array.map{ |elem| ActiveRubytter.new(elem)})}
      end

      it "入れ子でも元のHashを得られること" do
        @d.to_hash.should == @data
      end
    end
  end
end

