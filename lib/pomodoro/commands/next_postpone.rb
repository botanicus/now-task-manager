# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Next_Postpone < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>next-postpone</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    self.ensure_today

    edit_next_task_when_no_task_active(self.config) do |next_task|
      print "#{t(:prompt_why)} "
      reason = $stdin.readline.chomp
      print "#{t(:prompt_when)} "
      review_at = $stdin.readline.chomp

      review_date = if review_at.empty?
        next_task.postpone!(reason)
      else
        date = Date.strptime(review_at, '%d/%m')
        next_task.postpone!(reason, date)
      end

      puts t(:success, task: Pomodoro::Tools.unsentence(next_task.body), date: review_date.strftime('%-d/%-m'))
    end
  end
end
