require 'slack-ruby-bot'

module Satone
  module Command
    class Base < SlackRubyBot::Commands::Base
      def self.post_message(client, text, channel)
        client.message text: text, channel: channel
      end
    end
  end
end
