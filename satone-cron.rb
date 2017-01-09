require 'dotenv'
require 'holiday_jp'
require 'slack-ruby-client'

paths = %w(
  lib/satone/*.rb
  lib/satone/command/*.rb
  lib/satone/helper/*.rb
)

Dir[*paths].each { |f| load f }
Dotenv.load

class SatoneCron
  def self.can_post?
    !HolidayJp.holiday? Date.today
  end

  def self.run
    operation_type = ARGV[0]
    channel        = "\##{ARGV[1]}"
    # TODO: ARGV[2]以降でparamsを指定できるようにする

    return unless can_post?

    result = Satone::Routes.execute_cron_command(operation_type)

    Satone::SlackClient.post_message(params: result, channel: channel)
  end
end

SatoneCron.run
