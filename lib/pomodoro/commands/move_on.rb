class Pomodoro::Commands::MoveOn < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>move_on</magenta> <bright_black># <yellow>Move on</yellow> from the active task. Mark its end time, but don't set it as completed.</bright_black>
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          print "<bold>Why?</bold> "
          reason = STDIN.readline.chomp

          active_task.finish_for_the_day!(reason)
          puts "<bold>~</bold> You moved on from <green>#{Pomodoro::Tools.unsentence(active_task.body)}</green>."
        end
    else
      abort "<red>There is no task in progress.</red>"
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
