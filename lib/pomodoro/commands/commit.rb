require 'shellwords'

class Pomodoro::Commands::Commit < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>commit</magenta> <bright_black># #{self.description}</bright_black>
    now commit -a|-v
    now commit spec
      For this to work you have to be in the right directory.
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          commit_message = Shellwords.escape(active_task.body)
          arguments = [*@args, '-m', commit_message].join(' ')
          puts("#{t(:log_command, commit_message: commit_message)}\n\n")

          command("git commit #{arguments}")
        end
    else
      abort "<red>There is no task in progress.</red>" # TODO: raise NoTaskInProgress.
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
