class Pomodoro::Commands::Report < Pomodoro::Commands::Command
  self.description = "End of the day <magenta>report</magenta>."

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>report</magenta> pattern<bright_black># ...</bright_black>
  EOF

  def run
    today_list = parse_today_list(self.config).task_list if File.exist?(self.config.today_path)
    pattern = @args.shift
    selected_time_frames = today_list.time_frames.select { |time_frame| time_frame.name.match(/#{pattern}/) }
    selected_time_frames.each do |time_frame|
      puts "<cyan>#{time_frame.name}</cyan>"
      time_frame.tasks.each do |task|
        # Copied from bitbar.
        hash = {in_progress: 'yellow', completed: 'green', postponed: 'yellow'}
        hash.default_proc = Proc.new { 'bright_black' }
        colour = hash[task.status_x]

        print "<#{colour}>#{task}</#{colour}>"
      end
    end

    puts "\n<bold>Total time:</bold> #{selected_time_frames.reduce(0) { |sum, time_frame| time_frame.actual_duration + sum }}"
    puts "<bold>Cistyho casu:</bold> #{selected_time_frames.reduce(0) { |sum, time_frame| time_frame.duration_ + sum }}"
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
