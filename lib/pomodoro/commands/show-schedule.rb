require_relative 'generate'

module DateTimeMixin
  def next_week
    self + (7 - self.wday)
  end

  def next_wday(n)
    n > self.wday ? self + (n - self.wday) : self.next_week.next_day(n)
  end
end

class Pomodoro::Commands::ShowSchedule < Pomodoro::Commands::Generate
  self.help = <<-EOF.gsub(/^\s*/, '')
    now show-schedule
    now show-schedule +1
    now show-schedule holidays
    now show-schedule Saturday
  EOF

  def run
    if @args & Date::DAYNAMES
      day_name = (@args & Date::DAYNAMES).first
      wday  = Date::DAYNAMES.index(day_name)
      @date = Date.today.extend(DateTimeMixin).next_wday(wday)
      options = Hash.new ###
    else
      @date = Date.today + self.get_date_increment
    end

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
