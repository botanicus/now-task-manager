require 'abbrev'
require 'pomodoro/scheduler'

class Pomodoro::Commands::Generate < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now g u_ani +normal_daily_routine -swimming_daily_routine
  EOF

  def group_args
    template = {apply_rules: Array.new, remove_rules: Array.new}
    @args.reduce(template) do |buffer, argument|
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
  end

  def parse_date
    @args.delete('+1') ? Date.today + 1 : Date.today
  end

  def date_path
    self.config.today_path(@date)
  end

  def populate_from_schedule_and_rules(**options)
    scheduler = Pomodoro::Scheduler.load([self.config.schedule_path, self.config.routine_path], @date)

    schedule = if options[:schedule]
      unless scheduler.schedules[options[:schedule].to_sym]
        raise "No such schedule: #{options[:schedule]}. Valid are: #{scheduler.schedules.keys.inspect}"
      end
    else
      scheduler.schedule_for_date(@date)
    end

    day = schedule.call

    if day.empty?
      abort "<red>No data were found in the task list.</red>".colourise
    end

    scheduler.populate_from_rules(day.task_list)

    day
  end

  def match_time_frame_shortcut_with_time_frame(time_frames, shortcut)
    time_frames.find do |time_frame|
      abbrevs = Abbrev.abbrev([time_frame.name.upcase])

      time_frame.name.upcase == shortcut.upcase || # [Admin] [Morning ritual]
      abbrevs.include?(shortcut.upcase)         ||  # [ADM]  [MOR]
      time_frame.name.upcase.split(' ').map { |word| word[0] }.join == shortcut.upcase # [MR]
    end
  end

  def populate_from_scheduled_task_list(day, scheduled_task_list)
    scheduled_task_list.each do |task_group|
      if task_group.scheduled_date == @date
        task_group.tasks.each do |task|

          if task.time_frame
            time_frame = self.match_time_frame_shortcut_with_time_frame(
              day.task_list.time_frames, task.time_frame
            )

            unless time_frame
              raise "No such time frame: #{task.time_frame} in #{day.task_list.time_frames.map(&:name).inspect}"
            end
          end

          time_frame ||= day.task_list.time_frames.first

          puts "~ Adding #{task} to #{time_frame.name}"
          time_frame.items << Pomodoro::Formats::Today::Task.new(
            status: :not_done, body: task.body, tags: task.tags,
            fixed_start_time: task.start_time)
        end

        scheduled_task_list.delete(task_group)
      end
    end
  end

  def run
    @date = self.parse_date

    if File.exist?(self.date_path)
      abort "<red>Error:</red> File #{self.date_path.sub(ENV['HOME'], '~')} already exists.".colourise
    end

    options = self.group_args

    day = self.populate_from_schedule_and_rules(**options)

    system("vim #{self.config.task_list_path}")
    scheduled_task_list = parse_task_list(self.config)
    self.populate_from_scheduled_task_list(day, scheduled_task_list)

    day.task_list.save(self.date_path)
    scheduled_task_list.save(self.config.task_list_path)

    puts "~ <green>File #{date_path} has been created.</green>".colourise
  end
end
