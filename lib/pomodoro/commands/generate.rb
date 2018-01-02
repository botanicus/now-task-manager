require 'abbrev'
require 'pomodoro/scheduler'
require 'refined-refinements/homepath'

# TODO: maybe better "now plan tomorrow"?
class Pomodoro::Commands::Generate < Pomodoro::Commands::Command
  # TODO: now g u_ani +normal_daily_routine -swimming_daily_routine
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <red>g</red> holidays     <bright_black># Generate task list for today.</bright_black>
    now <red>g</red> +1 holidays  <bright_black># Generate task list for tomorrow.</bright_black>
      --dry-run
      --no-remove
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

  def date_path
    RR::Homepath.new(self.config.today_path(@date))
  end

  def get_schedule(scheduler, **options)
    if schedule_name = options.delete(:schedule)
      schedule = scheduler.schedules.find { |schedule| schedule.name == schedule_name.to_sym }
      unless schedule
        raise t(:no_such_schedule,
          schedule: schedule_name,
          schedules: scheduler.schedules.keys.inspect)
      end
    else
      schedule = scheduler.schedule_for_date(@date)
      unless schedule
        raise t(:no_schedule, date: @date.strftime('%d/%m'))
      end
    end

    schedule
  end

  def get_scheduler(date)
    Pomodoro::Scheduler.load([self.config.schedule_path, self.config.routine_path], date)
  end

  def populate_from_schedule_and_rules(**options)
    scheduler = self.get_scheduler(@date)
    schedule = self.get_schedule(scheduler, **options)

    puts t(:log_schedule, schedule: schedule.name)

    day = schedule.call

    abort t(:no_data_found) if day.empty?

    scheduler.populate_from_rules(day.task_list, **options.merge(schedule: schedule))

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

            # This is weird for skipped tasks.
            # unless time_frame
            #   raise t(:no_such_time_frame,
            #     time_frame: task.time_frame,
            #     time_frames: day.task_list.time_frames.map(&:name).inspect)
            # end
          end

          time_frame ||= day.task_list.time_frames.first

          puts t(:adding_task,
            task: Pomodoro::Tools.unsentence(task.body),
            time_frame: time_frame.name.downcase)

          time_frame.items << Pomodoro::Formats::Today::Task.new(
            status: :not_done, body: task.body, tags: task.tags,
            fixed_start_time: task.start_time)
        end

        scheduled_task_list.delete(task_group)
      end
    end
  end

  def add_postponed_task_to_scheduled_list(scheduled_task_list, time_frame, task)
    scheduled_date = task.metadata['Review at'] || (Date.today + 1).iso8601

    if Date.parse(scheduled_date) > @date + 1
      raise t(:cannot_be_today_or_earlier, date: scheduled_date, task: task.body)
    end

    if Date.parse(scheduled_date) == (@date + 1)
      formatted_scheduled_date = 'Tomorrow' # FIXME: What about if it is today?
    elsif Date.parse(scheduled_date) < (@date + 7)
      formatted_scheduled_date = Date.parse(scheduled_date).strftime('%A')
    else
      formatted_scheduled_date = Date.parse(scheduled_date).strftime('%-d/%-m')
    end

    task_group = scheduled_task_list[formatted_scheduled_date] || (
      scheduled_task_list << Pomodoro::Formats::Scheduled::TaskGroup.new(header: formatted_scheduled_date)
      scheduled_task_list[formatted_scheduled_date]
    )
    task_group << Pomodoro::Formats::Scheduled::Task.new(
      time_frame: time_frame.name, body: task.body, tags: task.tags)

    return scheduled_date
  end

  def add_upcoming_events_to_scheduled_list(scheduled_task_list)
    upcoming_events = self.config.calendar.select do |event_name, date|
      ((Date.today + 1)..(Date.today + 6)).include?(date)
    end

    unless upcoming_events.empty?
      # TODO: create new if no File.exist?(self.config.task_list_path)
      task_list = parse_task_list(self.config)
      upcoming_events.each do |event_name, date|
        puts t(:adding_upcoming, event: event_name, date: date.strftime('%A'))
        if task_group = task_list[date.strftime('%A')]
          task_group << event_name
        else
          task_list << Pomodoro::Formats::Scheduled::TaskGroup.new(header: date.strftime('%A'), tasks: [
            Pomodoro::Formats::Scheduled::Task.new(body: event_name)
          ])
        end
      end
    end
  end

  def run
    unless File.directory?(self.config.today_path_dir)
      command "mkdir #{self.config.today_path_dir}"
    end

    @date = Date.today + self.get_date_increment

    if self.date_path.exist?
      abort t(:already_exists, path: self.date_path)
    end

    previous_day_task_list_path = self.config.today_path(@date - 1)
    if File.exist?(previous_day_task_list_path)
      previous_day = Pomodoro::Formats::Today.parse(File.new(previous_day_task_list_path, encoding: 'utf-8'))
      # TODO: For skipped tasks, add them only if they weren't added by the rules.
      # WHY ask about voseo was added?
      postponed_tasks = previous_day.task_list.each_task_with_time_frame.select { |tf, task| task.postponed? || task.skipped?(tf) }
      unless postponed_tasks.empty?
        scheduled_task_list = parse_task_list(self.config)
        self.add_upcoming_events_to_scheduled_list(scheduled_task_list)

        puts t(:migrating_postponed, date: previous_day.date.strftime('%-d/%-m'))
        postponed_tasks.each do |time_frame, task|
          scheduled_date = add_postponed_task_to_scheduled_list(scheduled_task_list, time_frame, task)
          puts '  ' + t(:scheduling, task: Pomodoro::Tools.unsentence(task.body), date: scheduled_date.downcase)
        end

        if (@args & %w{--dry-run --no-remove}).empty?
          scheduled_task_list.save(self.config.task_list_path)
        end
        puts
      else
        puts t(:no_postponed_tasks, date: previous_day.date.strftime('%m/%d'))
      end
    end

    options = self.group_args

    day = self.populate_from_schedule_and_rules(**options)

    if (@args & %w{--dry-run --no-remove}).empty?
      command("vim #{self.config.task_list_path}")
    end

    scheduled_task_list = parse_task_list(self.config)
    self.populate_from_scheduled_task_list(day, scheduled_task_list)

    if @args.include?('--dry-run')
      puts "\n\n", day
    else
      day.save(self.date_path.expand)
      scheduled_task_list.save(self.config.task_list_path)

      puts t(:file_created, path: date_path)
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
