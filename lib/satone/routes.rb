require 'slack-ruby-bot'

module Satone
  class Routes < SlackRubyBot::Commands::Base
    # NOTE:
    # 各commandを実行する際の条件やハンドリングについてまとめたmoduleです。

    # match %r{regexp} とすると、botがjoinしているchannelの発言を拾って
    # regexpにマッチした場合にブロック内の処理を実行します。
    # ただし、複数の処理は行わないため単一のcommandを実行する場合に適しています。
    match %r{ping} do |client, data, match|
      result = Satone::Command::SimplePost.execute params: { name: :pong }

      Satone::SlackClient.post_message(client: client, params: result, channel: data.channel)
    end

    # scan %r{regexp} とすると、botがjoinしているchannelの発言を拾って
    # regexpにマッチした場合全てに対しブロック内の処理を実行します。
    # scanブロックに記述された内容は並列でtriggerが発動するため、
    # 発言に対して複数のcommandを実行したい場合に適しています。

    # crontab で定期的にpostする内容を定義します。
    # type / channel は satone-cron.rb を呼び出した際の第一 / 第二引数となります。
    def self.execute_cron_command(type)
      symbolized_type = type.to_sym

      case symbolized_type
      when :konami_alternate_notifier
        Satone::Command::KonamiAlternateNotifier.execute()
      else
        Satone::Command::SimplePost.execute params: { name: symbolized_type }
      end
    end
  end
end
