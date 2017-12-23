class Pomodoro::Commands::Next < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>next</green> <bright_black># Print the next task. Exit 1 if there is none.</bright_black>
  EOF

  def run
    # require 'pry'; binding.pry ###
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>"
    end

    with_active_task(self.config) do |active_task|
      warn "<yellow>There is a task in progress already:</yellow> #{unsentence(active_task.body)}.\n\n"
    end

    time_frame(self.config) do |today_list, current_time_frame|
      if next_task = current_time_frame.first_unstarted_task
        puts "<bold>~</bold> The upcoming task is <green>#{unsentence(next_task.body)}</green>."
      else
        abort "<red>No more tasks in #{current_time_frame.name}.</red>"
      end
    end
  rescue Pomodoro::Config::ConfigFileMissingError => error
    abort "<red>#{error.message}</red>"
  end
end
