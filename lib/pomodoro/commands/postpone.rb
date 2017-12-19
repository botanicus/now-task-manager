class Pomodoro::Commands::Postpone < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>postpone</magenta> <bright_black># Postpone the active task.</bright_black>
  EOF

  def run
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
    end

    print "<bold>Why?</bold> ".colourise
    reason = STDIN.readline.chomp
    print "<bold>When do you want to review?</bold> Defaults to tomorrow. ".colourise
    review_at = STDIN.readline.chomp

    # Ask for metadata and comments.
    with_active_task(self.config) do |active_task|
      review_at.empty? ? active_task.postpone!(reason) : active_task.postpone!(reason, review_at)
      puts "<bold>~</bold> <green>#{active_task.body}</green> has been postponed.".colourise
    end
  end
end
