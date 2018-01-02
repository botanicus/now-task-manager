class Pomodoro::Commands::Start < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>start</magenta> <bright_black># #{self.description}</bright_black>
    now <magenta>start</magenta> --confirm or -c <bright_black># Display the task and ask whether you want to start it.</bright_black>
  EOF

  def run
    ensure_today

    unless (@args & ['--confirm', '-c']).empty?
      Pomodoro::Commands::Next.new(Array.new).run
      print "\n#{t(:confirm)} "
      STDIN.readline
    end

    with_active_task(self.config) do |active_task|
      abort t(:task_in_progress, task: Pomodoro::Tools.unsentence(active_task.body))
    end

    edit_next_task_when_no_task_active(self.config) do |next_task, tf|
      next_task.start!

      # TODO: split, currently it doesn't save after the save, only after done.
      # TODO: ring bell.
      # TODO: is it supported in bitbar?
      if next_task.duration
        until next_task.remaining_duration(tf) == Hour.new(0)
          command("clear") # TODO: use ncurses.
          puts "<green>#{next_task.body}</green>"
          puts "<bold>~</bold> <yellow>Remaining:</yellow> <green>#{next_task.remaining_duration(tf)}</green>."
          sleep 10
        end
        command("clear")
        next_task.complete!
        puts t(:done, task: Pomodoro::Tools.unsentence(next_task.body))
      else
        puts t(:success, task: Pomodoro::Tools.unsentence(next_task.body))
      end
    end
  rescue Interrupt
    puts
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
