require 'slack-ruby-bot'
require 'dotenv'

paths = %w(
  lib/satone/*.rb
  lib/satone/command/*.rb
  lib/satone/helper/*.rb
)
Dir[*paths].each { |f| load f }

class SatoneBot < SlackRubyBot::Bot
  def initialize
    # 割り込みフラグ
    @flag_int = false
    @pid_file = "./satone-bot-daemon.pid"  # PID ファイル
  end

  def run
    begin
      daemonize()
      set_trap()

      self.class.superclass.run()
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.run] #{e}"
      exit 1
    end
  end

  def daemonize
    begin
      Process.daemon(true, true)

      # PID ファイル生成
      open(@pid_file, 'w') {|f| f << Process.pid} if @pid_file
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.daemonize] #{e}"
      exit 1
    end
  end

  # トラップ（割り込み）設定
  def set_trap
    begin
      Signal.trap(:INT)  {@flag_int = true}  # SIGINT  捕獲
      Signal.trap(:TERM) {@flag_int = true}  # SIGTERM 捕獲
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.set_trap] #{e}"
      exit 1
    end
  end
end

SatoneBot.new.run
