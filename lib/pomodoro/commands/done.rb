class Pomodoro::Commands::Done < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>done</magenta> <bright_black># Complete the active task.</bright_black>
  EOF

  def run
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
    end

    with_active_task(self.config) do |active_task|
      active_task.complete!
      puts "<bold>~</bold> <green>#{active_task.body}</green> has been finished.".colourise
    end
  end
end
