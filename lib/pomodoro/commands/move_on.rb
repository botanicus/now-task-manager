class Pomodoro::Commands::MoveOn < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>move_on</magenta> <bright_black># Move on from the active task. Mark its end time, but don't set it as completed.</bright_black>
  EOF

  def run
    must_exist(self.config.today_path)

    # Ask for metadata and comments.
    with_active_task(self.config) do |active_task|
      active_task.move_on!
      puts "<bold>~</bold> You moved on from <green>#{active_task.body}</green>.".colourise
    end
  end
end
