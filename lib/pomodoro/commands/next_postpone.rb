class Pomodoro::Commands::Next_Postpone < Pomodoro::Commands::Command
  self.description = "<yellow>Postpone</yellow> the next task."

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>next:postpone</magenta> <bright_black># ...</bright_black>
  EOF

  def run
    # Before we start asking, so we cannot wait for the exception.
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{Pomodoro::Tools.format_path(self.config.today_path)} doesn't exist</red>"
    end

    print "<bold>Why?</bold> "
    reason = STDIN.readline.chomp
    print "<bold>When do you want to review?</bold> Defaults to tomorrow. "
    review_at = STDIN.readline.chomp
    edit_next_task_when_no_task_active(self.config) do |next_task|
      review_at.empty? ? next_task.postpone!(reason) : next_task.postpone!(reason, review_at)
      puts "<bold>~</bold> Task <green>#{Pomodoro::Tools.unsentence(next_task.body)}</green> has been postponed."
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
