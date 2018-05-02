# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Done < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>done</magenta> <bright_black># #{self.description}</bright_black>
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          active_task.complete!
          puts t(:success, task: Pomodoro::Tools.unsentence(active_task.body))
        end
    else
      abort "<red>There is no task in progress.</red>"
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
