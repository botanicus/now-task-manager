# frozen_string_literal: true

# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Fail < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>fail</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    ensure_today

    if with_active_task(self.config) do |active_task|
          print "#{t(:prompt_why)} "
          reason = $stdin.readline.chomp

          active_task.fail!(reason)
          puts t(:success, task: Pomodoro::Tools.unsentence(active_task.body))
       end
    else
      abort t(:no_task_in_progress)
    end
  end
end
