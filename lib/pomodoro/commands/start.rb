class Pomodoro::Commands::Start < Pomodoro::Commands::Command
  self.description = "<green>Start</green> the next task."

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>start</magenta> <bright_black># #{self.description}</bright_black>
    now <magenta>start</magenta> --confirm or -c <bright_black># Display the task and ask whether you want to start it.</bright_black>
  EOF

  def run
    ensure_today

    unless (@args & ['--confirm', '-c']).empty?
      Pomodoro::Commands::Next.new(Array.new).run
      print "\n<bold>Start?</bold> " # TODO: Allow edit.
      STDIN.readline
    end

    with_active_task(self.config) do |active_task|
      abort "<red>There is an active task already:</red> #{Pomodoro::Tools.unsentence(active_task.body)}."
    end

    edit_next_task_when_no_task_active(self.config) do |next_task|
      puts "<bold>~</bold> Task <green>#{Pomodoro::Tools.unsentence(next_task.body)}</green> has been started."
      next_task.start!
    end
  rescue Interrupt
    puts
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
