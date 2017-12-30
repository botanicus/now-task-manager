class Pomodoro::Commands::Done < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>done</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          active_task.complete!
          puts "<bold>~</bold> Task <green>#{Pomodoro::Tools.unsentence(active_task.body)}</green> has been finished."
        end
    else
      abort "<red>There is no task in progress.</red>"
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
