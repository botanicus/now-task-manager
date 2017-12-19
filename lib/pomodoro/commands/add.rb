class Pomodoro::Commands::Add < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <red>+</red> [strings]<bright_black> # Add a task for later.</bright_black>
  EOF

  def run
    task_list = parse_task_list(self.config)
    task_list['Later'] ||= Array.new
    task_list['Later'] << ARGV.join(' ')
    task_list.save(self.config.task_list_path)
  end
end
