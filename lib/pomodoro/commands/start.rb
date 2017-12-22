class Pomodoro::Commands::Start < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>start</magenta> <bright_black># Start a new task.</bright_black>
  EOF

  def run
    must_exist(self.config.today_path)

    with_active_task(self.config) do |active_task|
      abort "<red>There is an active task already:</red> #{active_task.body}".colourise
    end

    edit_next_task_when_no_task_active(self.config) do |next_task|
      puts "<bold>~</bold> <green>#{next_task.body}</green> has been started.".colourise
      next_task.start!
    end
  rescue Pomodoro::Config::ConfigFileMissingError => error
    abort "<red>#{error.message}</red>"
  end
end
