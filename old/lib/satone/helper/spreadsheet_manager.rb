require 'google_drive'

module Satone
  module Helper
    class SpreadsheetManager
      CONFIG_JSON_PATH = 'spreadsheet_config.json'
      
      def initialize
        @file_manager = Satone::Helper::FileManager.new CONFIG_JSON_PATH
        @config = JSON.load @file_manager.fetch_all.join("\n")

        client_id     = @config["client_id"]
        client_secret = @config["client_secret"]
        refresh_token = @config["refresh_token"]

        client = OAuth2::Client.new(
          client_id,
          client_secret,
          site: "https://accounts.google.com",
          token_url: "/o/oauth2/token",
          authorize_url: "/o/oauth2/auth")

        auth_token = OAuth2::AccessToken.from_hash(client,{:refresh_token => refresh_token, :expires_at => 3600})
        auth_token = auth_token.refresh!
        @session = GoogleDrive.login_with_oauth(auth_token.token)
      end

      def insert(messages)
        ws = @session.spreadsheet_by_key(@config["spreadsheet_id"]).worksheets[0]
        insert_row = ws.num_rows + 1

        messages.each_with_index do |message, index|
          insert_column = index + 1
          ws[insert_row, insert_column] = message
        end

        ws.save
      end

      def search(word)
        ws = @session.spreadsheet_by_key(@config["spreadsheet_id"]).worksheets[0]

        matched_words = []
        [*1..ws.num_rows].each do |index|
          title = ws[index, 1]
          url   = ws[index, 2]
          matched_words.push "#{title}\n#{url}" if title.include? word
        end

        matched_words
      end
    end
  end
end
