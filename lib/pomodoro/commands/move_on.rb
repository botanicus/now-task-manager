class Pomodoro::Commands::MoveOn < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>move_on</magenta> <bright_black># Move on from the active task. Mark its end time, but don't set it as completed.</bright_black>
  EOF

  def run
    must_exist(self.config.today_path)

    if  with_active_task(self.config) do |active_task|
          print "<bold>Why?</bold> "
          reason = STDIN.readline.chomp
          
          active_task.move_on!(reason)
          puts "<bold>~</bold> You moved on from <green>#{unsentence(active_task.body)}</green>."
        end
    else
      abort "<red>There is no task in progress.</red>"
    end
  rescue Pomodoro::Config::ConfigFileMissingError => error
    abort "<red>#{error.message}</red>"
  end
end
