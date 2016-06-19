module Satone
  module Command
    class Ping < Base

      def self.message
        "pong"
      end
      
      match /ping/ do |client, data, match|
        post_message client, message, data.channel
      end
    end
  end
end
