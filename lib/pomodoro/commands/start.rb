class Pomodoro::Commands::Start < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>start</magenta> <bright_black># Start a new task.</bright_black>
  EOF

  def run
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
    end

    with_active_task(self.config) do |active_task|
      abort "<red>There is an active task already:</red> #{active_task.body}".colourise
    end

    edit_next_task_when_no_task_active(self.config) do |next_task|
      puts "<bold>~</bold> <green>#{next_task.body}</green> has been started.".colourise
      next_task.start!
    end
  end
end
