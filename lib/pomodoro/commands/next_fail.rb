class Pomodoro::Commands::Next_Fail < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>next:fail</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    # Before we start asking, so we cannot wait for the exception.
    today_path = RR::Homepath.new(self.config.today_path)

    unless today_path.exist? # FIXME
      abort "<red>! File #{today_path} doesn't exist</red>"
    end

    print "#{t(:prompt_why)} "
    reason = STDIN.readline.chomp
    edit_next_task_when_no_task_active(self.config) do |next_task|
      next_task.fail!(reason)
      puts t(:success, task: Pomodoro::Tools.unsentence(next_task.body))
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
