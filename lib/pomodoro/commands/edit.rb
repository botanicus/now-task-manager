class Pomodoro::Commands::Edit < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>e</green>                   <bright_black># Edit the today task file.</bright_black>
    now <green>e</green> <yellow>2</yellow>                 <bright_black># Edit both the today task file and tasks (in a split screen).</bright_black>
    now <green>e</green> <yellow>tasks</yellow> (or just <yellow>t</yellow>) <bright_black># Open the task file.</bright_black>
    now <green>e</green> <yellow>+1</yellow>                <bright_black># Edit the tomorrow task file.</bright_black>
    now <green>e</green> <yellow>schedules</yellow> (or just <yellow>s</yellow>) <bright_black># Open the task file.</bright_black>
    now <green>e</green> <yellow>config</yellow> (or just <yellow>c</yellow>) <bright_black># Open the task file.</bright_black>
  EOF

  def run
    case @args.first
    when nil
      self.ensure_today; command("nvim #{self.config.today_path}")
    when '2'
      # This could also be tomorrow + tasks, not just today + tasks.
      self.ensure_today; self.ensure_task_list
      command("nvim -O2 #{self.config.today_path} #{self.config.task_list_path}")
    when '+1'
      tomorrow = Date.today + 1; self.ensure_today(tomorrow)
      command("nvim #{self.config.today_path(tomorrow)}")
    when 'tasks', 't'
      self.ensure_task_list; command("nvim #{self.config.task_list_path}")
    when 'config', 'c'
      command("nvim #{self.config.path}") # TODO: spec
    when 'schedules', 's' # TODO: spec
      command("atom #{File.dirname(self.config.schedule_path)}")
    else
      abort(self.class.help)
    end
  end
end
