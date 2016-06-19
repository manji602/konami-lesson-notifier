require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'

module Satone
  module Command
    class RecipeAdder < Base

      def self.get_title_from_url(url)
        html = open(url, :allow_redirections => :all)
        doc = Nokogiri::HTML.parse html
        return nil unless doc

        doc.title
      end
      
      def self.message(params = {})
        url = params.fetch(:url, nil)
        return nil if url.nil?

        title = get_title_from_url url
        return nil if title.nil?

        spreadsheet_manager = Satone::Helper::SpreadsheetManager.new
        spreadsheet_manager.insert([title, url])

        "レシピ追加が終わったよ！"
      end

      match /(recipe)\p{blank}(add)\p{blank}(?<url>.*)/ do |client, data, match|
        url = match[:url].gsub(/<|>/, "<" => "", ">" => "")

        post_message client, message(url: url), data.channel
      end
    end
  end
end
