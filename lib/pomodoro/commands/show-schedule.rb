require_relative 'generate'

class Pomodoro::Commands::ShowSchedule < Pomodoro::Commands::Generate
  self.help = <<-EOF.gsub(/^\s*/, '')
    now show-schedule
    now show-schedule +1
    now show-schedule holidays
  EOF

  def run
    @date = self.parse_date
    options = self.group_args
    schedule = self.get_schedule(**options)
    day = schedule.call
    day.task_list.time_frames.each do |time_frame|
      STDOUT.puts time_frame
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
