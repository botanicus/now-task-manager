require_relative 'generate'

class Pomodoro::Commands::ShowSchedule < Pomodoro::Commands::Generate
  self.help = <<-EOF.gsub(/^\s*/, '')
    now show-schedule
    now show-schedule +1
    now show-schedule holidays
  EOF

  def run
    @date = Date.today + self.get_date_increment
    options = self.group_args
    scheduler = self.get_scheduler(@date)
    schedule = self.get_schedule(scheduler, **options)
    day = schedule.call
    day.task_list.time_frames.each do |time_frame|
      puts time_frame
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
