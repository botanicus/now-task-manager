# Status: unsure whether we want it https://github.com/botanicus/now-task-manager/issues/121
class Pomodoro::Commands::MoveOn < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>move_on</magenta> <bright_black># <yellow>Move on</yellow> from the active task. Mark its end time, but don't set it as completed.</bright_black>
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          # Without this, it looks like it has been done.
          #print "#{t(:prompt_why)} "
          #reason = STDIN.readline.chomp

          active_task.finish_for_the_day!#(reason)
          puts t(:success, task: Pomodoro::Tools.unsentence(active_task.body))
        end
    else
      abort t(:no_task_in_progress)
    end
  end
end
