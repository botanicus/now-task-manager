class Pomodoro::Commands::FailNext < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>fail-next</magenta> <bright_black># ...</bright_black>
  EOF

  def run
    # Before we start asking, so we cannot wait for the exception.
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
    end

    print "<bold>Why?</bold> ".colourise
    reason = STDIN.readline.chomp
    edit_next_task_when_no_task_active(self.config) do |next_task|
      next_task.fail!(reason)
      puts "<bold>~</bold> <green>#{next_task.body}</green> has been failed.".colourise
    end
  end
end
