class Pomodoro::Commands::TickOffNext < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>tick-off-next</magenta> <bright_black># ...</bright_black>
  EOF

  def run
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
    end

    edit_next_task_when_no_task_active(self.config) do |next_task|
      next_task.complete!
      puts "<bold>~</bold> <green>#{next_task.body}</green> has been finished.".colourise
    end
  end
end
