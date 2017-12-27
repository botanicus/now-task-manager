class Pomodoro::Commands::Next < Pomodoro::Commands::Command
  self.description = "Display the next task."

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>next</green> <bright_black># Print the next task. Exit 1 if there is none.</bright_black>
  EOF

  def run
    ensure_today

    with_active_task(self.config) do |active_task|
      warn "<yellow>There is a task in progress already:</yellow> #{Pomodoro::Tools.unsentence(active_task.body)}.\n\n"
    end

    time_frame(self.config) do |day, current_time_frame|
      if next_task = current_time_frame.first_unstarted_task
        puts "<bold>~</bold> The upcoming task is <green>#{Pomodoro::Tools.unsentence(next_task.body)}</green>."
      else
        abort "<red>No more tasks in #{current_time_frame.name}.</red>"
      end
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
