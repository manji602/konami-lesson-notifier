require 'json'

module Satone
  module Helper
    class Secrets
      SECRETS_JSON_PATH = "satone-secrets.json"

      def self.fetch(key)
        raw_secrets = Satone::Helper::FileManager.new(SECRETS_JSON_PATH).fetch_all.join("\n")
        secrets = JSON.load raw_secrets

        secrets[key]
      end
    end
  end
end
