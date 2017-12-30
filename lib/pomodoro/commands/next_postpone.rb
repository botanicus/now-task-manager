class Pomodoro::Commands::Next_Postpone < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>next:postpone</magenta> <bright_black># ...</bright_black>
  EOF

  def run
    # Before we start asking, so we cannot wait for the exception.
    today_path = RR::Homepath.new(self.config.today_path)

    unless today_path.exist? # FIXME
      abort "<red>! File #{today_path} doesn't exist</red>"
    end

    print "#{t(:prompt_why)} "
    reason = $stdin.readline.chomp
    print "#{t(:prompt_when)} "
    review_at = $stdin.readline.chomp
    edit_next_task_when_no_task_active(self.config) do |next_task|
      review_date = if review_at.empty?
        next_task.postpone!(reason)
      else
        next_task.postpone!(reason, Date.strptime(review_at, '%d/%m'))
      end
      puts t(:success, task: Pomodoro::Tools.unsentence(next_task.body), date: review_date.strftime('%-d/%-m'))
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
