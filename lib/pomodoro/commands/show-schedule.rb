# frozen_string_literal: true

require_relative 'generate'

module DateTimeMixin
  def next_week
    self + (7 - self.wday)
  end

  def next_wday(n)
    unless n.is_a?(Integer)
      raise ArgumentError, "DateTimeMixin#next_wday expects Integer, got #{n.class}."
    end

    n > self.wday ? self + (n - self.wday) : self.next_week.next_day(n)
  end
end

class Pomodoro::Commands::ShowSchedule < Pomodoro::Commands::Generate
  self.help = <<-EOF.gsub(/^\s*/, '')
    #{self.description}
    now show-schedule
    now show-schedule +1
    now show-schedule holidays
    now show-schedule Saturday
  EOF

  def run
    if Date::DAYNAMES.include?(@args.first)
      # now show-schedule Saturday
      day_name = (@args & Date::DAYNAMES).first
      wday  = Date::DAYNAMES.index(day_name)
      @date = Date.today.extend(DateTimeMixin).next_wday(wday)
      options = Hash.new
    elsif @args.first.nil? || @args[0].match(/^\+\d+$/)
      # now show-schedule +1
      @date = Date.today + self.get_date_increment
      options = Hash.new
    else
      # now show-schedule holidays
      @date = Date.today + 1
      options = group_args.slice(:schedule)
    end

    scheduler = self.get_scheduler(@date)
    schedule = self.get_schedule(scheduler, **options)
    day = schedule.call
    day.task_list.time_frames.each do |time_frame|
      puts time_frame
    end
  end
end
