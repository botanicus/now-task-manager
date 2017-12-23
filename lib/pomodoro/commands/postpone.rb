class Pomodoro::Commands::Postpone < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>postpone</magenta> <bright_black># Postpone the active task.</bright_black>
  EOF

  def run
    must_exist(self.config.today_path)

    print "<bold>Why?</bold> "
    reason = STDIN.readline.chomp
    print "<bold>When do you want to review?</bold> Defaults to tomorrow. "
    review_at = STDIN.readline.chomp

    # Ask for metadata and comments.
    with_active_task(self.config) do |active_task|
      review_at.empty? ? active_task.postpone!(reason) : active_task.postpone!(reason, review_at)
      puts "<bold>~</bold> <green>#{active_task.body}</green> has been postponed."
    end
  rescue Pomodoro::Config::ConfigFileMissingError => error
    abort "<red>#{error.message}</red>"
  end
end
