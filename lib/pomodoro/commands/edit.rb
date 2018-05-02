# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Edit < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>e</green>                   <bright_black># Edit the today task file.</bright_black>
    now <green>e</green> <yellow>2</yellow>                 <bright_black># Edit both the today task file and tasks (in a split screen).</bright_black>
    now <green>e</green> <yellow>tasks</yellow> (or just <yellow>t</yellow>) <bright_black># Open the task file.</bright_black>
    now <green>e</green> <yellow>+1</yellow>                <bright_black># Edit the tomorrow task file.</bright_black>
  EOF

  def run
    if @args.empty?
      self.ensure_today; command("vim #{self.config.today_path}")
    elsif @args.first.to_i == 2 # This could also be tomorrow + tasks, not just today + tasks.
      self.ensure_today; self.ensure_task_list
      command("vim -O2 #{self.config.today_path} #{self.config.task_list_path}")
    elsif @args.first == '+1'
      tomorrow = Date.today + 1; self.ensure_today(tomorrow)
      command("vim #{self.config.today_path(tomorrow)}")
    elsif ['tasks', 't'].include?(@args.first)
      self.ensure_task_list; command("vim #{self.config.task_list_path}")
    elsif ['config', 'c'].include?(@args.first)
      command("vim #{self.config.path}") # TODO: spec
    else
      abort(self.class.help)
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
