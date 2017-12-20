require 'abbrev'
require 'pomodoro/scheduler'

class Pomodoro::Commands::Generate < Pomodoro::Commands::Command
  using RR::ColourExts

  # TODO: now g u_ani +normal_daily_routine -swimming_daily_routine
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <red>g</red> holidays     <bright_black># Generate task list for today.</bright_black>
    now <red>g</red> +1 holidays  <bright_black># Generate task list for tomorrow.</bright_black>
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

    if schedule_name = options.delete(:schedule)
      schedule = scheduler.schedules.find { |schedule| schedule.name == schedule_name.to_sym }
      unless schedule
        raise "No such schedule: #{schedule_name}. Valid are: #{scheduler.schedules.keys.inspect}"
      end
    else
      schedule = scheduler.schedule_for_date(@date)
      unless schedule
        raise "Cannot find any schedule for #{@date.strftime('%d/%m')}"
      end
    end

    puts "~ Schedule: <magenta>#{schedule.name}</magenta>.".colourise

    day = schedule.call

    if day.empty?
      abort "<red>No data were found in the task list.</red>".colourise
    end

    scheduler.populate_from_rules(day.task_list, schedule: schedule, **options)

    day
  end

  def match_time_frame_shortcut_with_time_frame(time_frames, shortcut)
    time_frames.find do |time_frame|
      abbrevs = Abbrev.abbrev([time_frame.name.upcase.delete(' ')])

      time_frame.name.upcase == shortcut.upcase || # [Admin] [Morning ritual]
      time_frame.name.upcase.split(' ').map { |word| word[0] }.join == shortcut.upcase || # [MR]
      abbrevs.include?(shortcut.upcase)            # [ADM]  [MOR]
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

          puts "~ Adding <green>#{task.body}</green> to <magenta>#{time_frame.name.downcase}</magenta>.".colourise
          time_frame.items << Pomodoro::Formats::Today::Task.new(
            status: :not_done, body: task.body, tags: task.tags,
            fixed_start_time: task.start_time)
        end

        scheduled_task_list.delete(task_group)
      end
    end
  end

  def add_postponed_task_to_scheduled_list(scheduled_task_list, time_frame, task)
    scheduled_date = task.metadata['Review at'] || Date.today.iso8601

    if Date.parse(scheduled_date) == (Date.today + 1)
      scheduled_date = 'Tomorrow' # FIXME: What about if it is today?
    end

    task_group = scheduled_task_list[scheduled_date] || (
      scheduled_task_list << Pomodoro::Formats::Scheduled::TaskGroup.new(header: scheduled_date)
      scheduled_task_list[scheduled_date]
    )
    task_group << Pomodoro::Formats::Scheduled::Task.new(time_frame: time_frame.name, body: task.body, tags: task.tags)

    return scheduled_date
  end

  def run
    @date = self.parse_date

    if File.exist?(self.date_path)
      abort "<red>Error:</red> File #{self.date_path.sub(ENV['HOME'], '~')} already exists.".colourise
    end

    previous_day_task_list_path = self.config.today_path(@date - 1)
    if File.exist?(previous_day_task_list_path)
      previous_day = Pomodoro::Formats::Today.parse(File.new(previous_day_task_list_path, encoding: 'utf-8'))
      postponed_tasks = previous_day.task_list.each_task_with_time_frame.select { |tf, task| task.postponed? }
      unless postponed_tasks.empty?
        puts "~ <green>Migrating postponed tasks</green> from #{previous_day.date.strftime('%d/%m')}.".colourise
        scheduled_task_list = parse_task_list(self.config)
        postponed_tasks.each do |time_frame, task|
          scheduled_date = add_postponed_task_to_scheduled_list(scheduled_task_list, time_frame, task)
          puts "  ~ Scheduling <green>#{task.body}</green> for <yellow>#{scheduled_date.downcase}</yellow>.".colourise
        end
        scheduled_task_list.save(self.config.task_list_path)
        puts
      else
        puts "~ <green>No postponed tasks</green> from #{previous_day.date.strftime('%m/%d')}.".colourise
      end

      # TODO: Warn about skipped tasks and print their list, wait for the user to acknowledge (STDIN.readline).
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
