require 'slack-ruby-bot'

paths = %w(
  lib/satone/*.rb
  lib/satone/command/*.rb
  lib/satone/helper/*.rb
)
Dir[*paths].each { |f| load f }

class SatoneBot < SlackRubyBot::Bot
end

SatoneBot.run
