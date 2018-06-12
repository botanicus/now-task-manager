# frozen_string_literal: true

# 1/5/2018: specs complete, help complete.
require 'shellwords'

class Pomodoro::Commands::Commit < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>commit</magenta> <bright_black># #{self.description}</bright_black>
    now <magenta>commit</magenta> -a|-v
    now <magenta>commit</magenta> spec
      For this to work you have to be in the right directory.

      If the current task has a numeric tag (i. e. <bright_black>#112</bright_black>),
      then it will be closed using the <bright_black>Closes #num</bright_black> syntax.
  EOF

  def run
    ensure_today

    if with_active_task(self.config) do |active_task|
          tag = active_task.tags.find { |tag| tag.match(/^\d+$/) }
          body = [active_task.body, tag && "Closes ##{tag}"].compact.join(' ')
          # TODO: closes vs. mention only? Shall we use commit -v?
          commit_message = Shellwords.escape(body)
          arguments = [*@args, '-m', commit_message].join(' ')
          puts("#{t(:log_command, commit_message: commit_message)}\n\n")

          command("git commit #{arguments}")
       end
    else
      abort t(:no_task_in_progress) # TODO: raise NoTaskInProgress.
    end
  end
end
