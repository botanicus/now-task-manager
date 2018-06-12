# frozen_string_literal: true

# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Next_Fail < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>next:fail</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    self.ensure_today

    edit_next_task_when_no_task_active(self.config) do |next_task|
      print "#{t(:prompt_why)} "
      reason = $stdin.readline.chomp
      next_task.fail!(reason)
      puts t(:success, task: Pomodoro::Tools.unsentence(next_task.body))
    end
  end
end
