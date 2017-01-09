require 'slack-ruby-client'

module Satone
  class SlackClient
    def self.post_message(client: nil, params: {}, channel: nil)
      return if channel.nil?
      return if params[:text].nil? && params[:attachments].nil?

      options = params.merge({ channel: channel, as_user: true })

      if client.nil?
        post_message_via_web_client(options)
      else
        post_message_via_realtime_client(client, options)
      end
    end

    def self.post_message_via_web_client(options)
      client = build_slack_client()

      client.chat_postMessage options
    end

    def self.post_message_via_realtime_client(client, options)
      client.message options
    end

    private

    def self.build_slack_client
      Slack.configure do |config|
        config.token = Satone::Helper::Secrets.fetch("slack_api_token")
      end

      client = Slack::Web::Client.new
      client.auth_test

      client
    end
  end
end
