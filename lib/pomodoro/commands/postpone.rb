# frozen_string_literal: true

# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Postpone < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>postpone</magenta> <bright_black># Postpone the active task.</bright_black>
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          print "#{t(:prompt_why)} "
          reason = $stdin.readline.chomp
          print "#{t(:prompt_when)} "
          review_at = $stdin.readline.chomp

          if review_at.empty?
            review_date = active_task.postpone!(reason)
          else
            review_date = Date.strptime(review_at, '%d/%m')
            review_date = active_task.postpone!(reason, review_date)
          end

          puts t(:success, task: Pomodoro::Tools.unsentence(active_task.body), date: review_date.strftime('%-d/%-m'))
        end
    else
      abort t(:no_task_in_progress)
    end
  end
end
