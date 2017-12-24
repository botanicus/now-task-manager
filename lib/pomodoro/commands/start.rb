class Pomodoro::Commands::Start < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>start</magenta> <bright_black># Start a new task.</bright_black>
  EOF

  def run
    ensure_today

    with_active_task(self.config) do |active_task|
      abort "<red>There is an active task already:</red> #{Pomodoro::Tools.unsentence(active_task.body)}."
    end

    edit_next_task_when_no_task_active(self.config) do |next_task|
      puts "<bold>~</bold> Task <green>#{Pomodoro::Tools.unsentence(next_task.body)}</green> has been started."
      next_task.start!
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
