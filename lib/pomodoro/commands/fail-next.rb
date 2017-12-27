class Pomodoro::Commands::FailNext < Pomodoro::Commands::Command
  self.description = "<red>Fail</red> the next command."

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>fail-next</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    # Before we start asking, so we cannot wait for the exception.
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{Pomodoro::Tools.format_path(self.config.today_path)} doesn't exist</red>"
    end

    print "<bold>Why?</bold> "
    reason = STDIN.readline.chomp
    edit_next_task_when_no_task_active(self.config) do |next_task|
      next_task.fail!(reason)
      puts "<bold>~</bold> Task <green>#{Pomodoro::Tools.unsentence(next_task.body)}</green> has been failed."
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
