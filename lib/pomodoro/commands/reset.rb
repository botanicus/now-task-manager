# frozen_string_literal: true

class Pomodoro::Commands::Reset < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>done</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          active_task.reset!
          puts t(:success, task: Pomodoro::Tools.unsentence(active_task.body))
        end
    else
      abort t(:no_task_in_progress)
    end
  end
end
