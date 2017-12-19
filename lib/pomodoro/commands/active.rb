class Pomodoro::Commands::Active < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>active</green> '%b' <bright_black># Print the active task.</bright_black>
  EOF

  def run
    must_exist(self.config.today_path)
    today_list = parse_today_list(self.config)

    if active_task = today_list.active_task
      format_string = (@args.shift || '%b').dup
      format_string.gsub!('%b', active_task.body)
      # TODO ...
      puts format_string
    else
      abort "<red>No active tasks.</red>".colourise
    end
  end
end
