module Satone
  module Command
    class RecipeLister < Base
      def self.message(params = {})
        word = params.fetch(:word, nil)
        return nil if word.nil?

        spreadsheet_manager = Satone::Helper::SpreadsheetManager.new
        lines = spreadsheet_manager.search word
        lines.join("\n")
      end
      
      match /(recipe)\p{blank}(search)\p{blank}(?<word>.*)/ do |client, data, match|
        word = match[:word]
        post_message client, message(word: word), data.channel
      end
    end
  end
end
