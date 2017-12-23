class Pomodoro::Commands::Edit < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>edit</green>, now <green>e</green>
      <bright_black>now e</bright_black> Edit the today task file, creating it if it doesn't exist.
      <bright_black>now e <yellow>2</yellow></bright_black> Edit both the today task file and tasks (in a split screen).
      <bright_black>now e <yellow>tasks</yellow></bright_black> (or just <yellow>t</yellow>) Open the task file.
      <bright_black>now e <yellow>tomorrow</yellow></bright_black> Plan tomorrow.
  EOF

  def ensure_today(*args)
    unless self.config.today_path
      raise Pomodoro::Config::ConfigError.new('today_path')
    end

    self.must_exist(self.config.today_path(*args), "Run the g command first.")
  end

  def ensure_task_list
    unless self.config.task_list_path
      raise Pomodoro::Config::ConfigError.new('task_list_path')
    end

    self.must_exist(self.config.task_list_path)
  end

  def run
    if @args.empty?
      self.ensure_today && command("vim #{self.config.today_path}")
    elsif @args.first.to_i == 2 # This could also be tomorrow + tasks, not just today + tasks.
      self.ensure_today; self.ensure_task_list
      command("vim -O2 #{self.config.today_path} #{self.config.task_list_path}")
    elsif @args.first == 'tomorrow'
      tomorrow = Date.today + 1; self.ensure_today(tomorrow)
      command("vim #{self.config.today_path(tomorrow)}")
    elsif ['tasks', 't'].include?(@args.first)
      self.ensure_task_list; command("vim #{self.config.task_list_path}")
    else
      abort(self.class.help)
    end
  rescue Pomodoro::Config::ConfigFileMissingError, Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
