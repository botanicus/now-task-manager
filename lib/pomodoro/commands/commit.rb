class Pomodoro::Commands::Commit < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>commit</magenta> <bright_black># ...</bright_black>
    now commit -a|-v
    now commit spec
      For this to work you have to be in the right directory.
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          arguments = [*@args, '-m', "'#{active_task.body}'"].join(' ')
          puts("<bold>~</bold> Running <bright_black>git commit #{arguments}</bright_black>.\n\n")
          command("git commit #{arguments}")
        end
    else
      abort "<red>There is no task in progress.</red>"
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
