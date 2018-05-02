# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Next < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>next</green> <bright_black># Print the next task. Exit 1 if there is none.</bright_black>
  EOF

  def run
    ensure_today

    with_active_task(self.config) do |active_task|
      warn "#{t(:task_in_progress, task: Pomodoro::Tools.unsentence(active_task.body))}\n\n"
    end

    time_frame(self.config) do |day, current_time_frame|
      if next_task = current_time_frame.first_unstarted_task
        puts t(:upcoming_task, task: Pomodoro::Tools.unsentence(next_task.body))
      else
        abort "<red>No more tasks in #{current_time_frame.name}.</red>"
      end
    end
  end
end
