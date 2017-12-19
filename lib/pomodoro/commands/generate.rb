class Pomodoro::Commands::Generate < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
  EOF

  def run
    template = {apply_rules: Array.new, remove_rules: Array.new}
    options = ARGV.reduce(template) do |buffer, argument|
      case argument
      when /^\+/
        buffer[:apply_rules] << argument[1..-1]
      when /^-/
        buffer[:remove_rules] << argument[1..-1]
      else
        buffer[:schedule] = argument
      end

      buffer
    end

    # TODO: allow choosing date
    # now generate holidays    # => today
    # now generate +1 holidays # => tomorrow
    generate_todays_tasks(Date.today, self.config, **options)
  end
end

 # now g u_ani +normal_daily_routine -swimming_daily_routine
def generate_todays_tasks(date, config, **options)
  require 'pomodoro/scheduler'

  date_path = self.config.today_path(date)

  return date_path if File.exist?(self.config.today_path(date))

  system("vim #{self.config.task_list_path}")

  scheduler = Pomodoro::Scheduler.load([self.config.schedule_path, self.config.routine_path], date)

  schedule = options[:schedule] ? scheduler.schedules[options[:schedule]] : scheduler.schedule_for_date(date)
  day = schedule.call

  if day.empty?
    abort "<red>No data were found in the task list.</red>".colourise
  end

  scheduler.populate_from_rules(day.task_list)

  scheduled_task_list = parse_task_list(self.config)

  scheduled_task_list.each do |task_group|
    if task_group.scheduled_date == date
      task_group.tasks.each do |task|

        pieces = task.split(/:\s+/)[0]
        if pieces.length > 1
          possible_time_frame_name, *rest = pieces
          require 'abbrev'

          time_frame = day.task_list.time_frames.find do |time_frame|
            time_frame.name == possible_time_frame_name || begin
              if possible_time_frame_name.match(/^[A-Z]{2,}\d?$/) # Use MOR: to match Morning routine etc.
                abbrevs = Abbrev.abbrev([time_frame.name.upcase])
                abbrevs[possible_time_frame_name]
              end
            end
          end
          task = rest.join(': ').strip if time_frame
        end

        unless time_frame
          time_frame = day.task_list.time_frames.first
        end

        puts "~ Adding #{task} to #{time_frame.name}"
        time_frame.create_task(task)
        scheduled_task_list.delete(task_group)
      end
    end
  end

  day.task_list.save(date_path)
  scheduled_task_list.save(self.config.task_list_path)

  return date_path
end
