class Pomodoro::Commands::TickOffNext < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>tick-off-next</magenta> <bright_black># ...</bright_black>
  EOF

  def run
    must_exist(self.config.today_path)

    edit_next_task_when_no_task_active(self.config) do |next_task|
      next_task.complete!
      puts "<bold>~</bold> <green>#{next_task.body}</green> has been finished.".colourise
    end
  rescue Pomodoro::Config::ConfigFileMissingError => error
    abort "<red>#{error.message}</red>"
  end
end
