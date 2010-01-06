# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'Termtter::Client.post_retweet' do
  describe 'posts a retweet based on the given post by someone,' do
    describe 'with your own comment,' do
      it 'and without confirming in the original post being not protected' do
        Termtter::Client.plug 'defaults/retweet'

        mock = Object.new
        def mock.user
          mock2 = Object.new
          def mock2.protected
            false
          end

          def mock2.screen_name
            'ujihisa'
          end
          mock2
        end

        def mock.text
          'hi'
        end

        mock3 = Object.new
        def mock3.update(text)
          text
        end

        Termtter::API.should_receive(:twitter).and_return(mock3)
        $stdout = StringIO.new
        Termtter::Client.post_retweet(mock, 'my comment')
        $stdout = STDOUT
      end
    end
  end
end

describe 'Plugin `retweet`' do
  it 'registers a commond when it is loaded' do
    Termtter::Client.should_receive(:register_command).at_least(5).times
    Termtter::Client.plug 'defaults/retweet'
  end
end
