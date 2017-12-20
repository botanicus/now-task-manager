class Pomodoro::Commands::Next < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>next</green> <bright_black># Print the next task. Exit 1 if there is none.</bright_black>
  EOF

  def run
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
    end

    with_active_task(self.config) do |active_task|
      abort "<red>There is an active task already:</red> #{active_task.body}".colourise
    end

    time_frame(self.config) do |today_list, current_time_frame|
      if next_task = current_time_frame.first_unstarted_task
        puts "<bold>~</bold> <green>#{next_task.body}</green>".colourise
      else
        abort "<red>No more tasks in #{current_time_frame.desc}</red>".colourise
      end
    end
  end
end
