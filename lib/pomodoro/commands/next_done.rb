class Pomodoro::Commands::Next_Done < Pomodoro::Commands::Command
  self.description = "<green>Complete</green> the next task."

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>next:done</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    ensure_today

    edit_next_task_when_no_task_active(self.config) do |next_task|
      next_task.complete!
      puts "<bold>~</bold> Task <green>#{Pomodoro::Tools.unsentence(next_task.body)}</green> has been finished."
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
