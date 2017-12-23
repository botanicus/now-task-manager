class Pomodoro::Commands::Done < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>done</magenta> <bright_black># Complete the active task.</bright_black>
  EOF

  def run
    must_exist(self.config.today_path)

    if  with_active_task(self.config) do |active_task|
          active_task.complete!
          puts "<bold>~</bold> <green>#{unsentence(active_task.body)}</green> has been finished."
        end
    else
      abort "<red>There is no task in progress.</red>"
    end
  rescue Pomodoro::Config::ConfigFileMissingError => error
    abort "<red>#{error.message}</red>"
  end
end
