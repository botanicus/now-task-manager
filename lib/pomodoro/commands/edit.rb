class Pomodoro::Commands::Edit < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>edit</green>, now <green>e</green>
      <bright_black>now e</bright_black> Edit the today task file, creating it if it doesn't exist.
      <bright_black>now e <yellow>2</yellow></bright_black> Edit both the today task file and tasks (in a split screen).
      <bright_black>now e <yellow>tasks</yellow></bright_black> (or just <yellow>t</yellow>) Open the task file.
      <bright_black>now e <yellow>tomorrow</yellow></bright_black> Plan tomorrow.
  EOF

  def run
    if @args.empty?
      unless File.exists?(self.config.today_path)
        system("vim #{self.config.task_list_path}")
      end
      date_path = generate_todays_tasks(Date.today, self.config)
      exec("vim #{date_path}")
    elsif @args.first.to_i == 2
      system("vim #{self.config.task_list_path}")
      date_path = generate_todays_tasks(Date.today, self.config)
      exec("vim -O2 #{date_path} #{self.config.task_list_path}")
    elsif @args.first == 'tomorrow'
      date_path = generate_todays_tasks(Date.today + 1, self.config)
      exec("vim #{date_path}")
    elsif ['tasks', 't'].include?(@args.first)
      exec("vim #{self.config.task_list_path}")
    else
      abort(DATA.read.colourise)
    end
  end
end
