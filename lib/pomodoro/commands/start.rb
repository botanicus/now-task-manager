class Pomodoro::Commands::Start < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>start</magenta> <bright_black># #{self.description}</bright_black>
    now <magenta>start</magenta> --confirm or -c <bright_black># Display the task and ask whether you want to start it.</bright_black>
  EOF

  def run
    ensure_today

    unless (@args & ['--confirm', '-c']).empty?
      Pomodoro::Commands::Next.new(Array.new).run
      print "\n#{t(:confirm)} "
      STDIN.readline
    end

    with_active_task(self.config) do |active_task|
      abort t(:task_in_progress, task: Pomodoro::Tools.unsentence(active_task.body))
    end

    edit_next_task_when_no_task_active(self.config) do |next_task|
      next_task.start!
      puts t(:success, task: Pomodoro::Tools.unsentence(next_task.body))
    end
  rescue Interrupt
    puts
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
