class Pomodoro::Commands::PostponeNext < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>postpone-next</magenta> <bright_black># ...</bright_black>
  EOF

  def run
    # Before we start asking, so we cannot wait for the exception.
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
    end

    print "<bold>Why?</bold> ".colourise
    reason = STDIN.readline.chomp
    print "<bold>When do you want to review?</bold> Defaults to tomorrow. ".colourise
    review_at = STDIN.readline.chomp
    edit_next_task_when_no_task_active(self.config) do |next_task|
      review_at.empty? ? next_task.postpone!(reason) : next_task.postpone!(reason, review_at)
      puts "<bold>~</bold> <green>#{next_task.body}</green> has been postponed.".colourise
    end
  end
end