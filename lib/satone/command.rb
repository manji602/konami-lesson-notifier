require 'slack-ruby-bot'

module Satone
  module Command
    class Base < SlackRubyBot::Commands::Base
      def self.usage
        nil
      end

      def self.execute(params: {})
        fail NoImplementedError
      end
    end
  end
end
