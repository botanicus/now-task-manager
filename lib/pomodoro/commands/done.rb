class Pomodoro::Commands::Done < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>done</magenta> <bright_black># Complete the active task.</bright_black>
  EOF

  def run
    must_exist(self.config.today_path)

    with_active_task(self.config) do |active_task|
      active_task.complete!
      puts "<bold>~</bold> <green>#{active_task.body}</green> has been finished.".colourise
    end
  rescue Pomodoro::Config::ConfigFileMissingError => error
    abort "<red>#{error.message}</red>"
  end
end
