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
      if File.exists?(self.config.today_path)
        system("vim #{self.config.today_path}")
      else
        abort "<red>Error:</red> File #{self.config.task_list_path} doesn't exist.\n  Run the g command first.".colourise
      end
    elsif @args.first.to_i == 2 # This could also be tomorrow + tasks, not just today + tasks.
      exec("vim -O2 #{self.config.today_path} #{self.config.task_list_path}")
    elsif @args.first == 'tomorrow'
      if File.exists?(self.config.today_path(Date.today + 1))
        system("vim #{self.config.today_path(Date.today + 1)}")
      else
        abort "<red>Error:</red> File #{self.config.task_list_path} doesn't exist.\n  Run the g command first.".colourise
      end
    elsif ['tasks', 't'].include?(@args.first)
      exec("vim #{self.config.task_list_path}")
    else
      abort('DATA.read.colourise') # FIXME
    end
  end
end
