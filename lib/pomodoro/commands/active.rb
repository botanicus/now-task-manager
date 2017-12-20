class Pomodoro::Commands::Active < Pomodoro::Commands::Command
  using RR::ColourExts

  FORMATTERS ||= {
    body: '%b',
    start_time: '%f',
    duration: '%d',
    # remaining_duration: # TODO: This takes arguments.
  }

  self.help = <<-EOF
    <bright_black># Print the active task. Exit 1 if there is none.</bright_black>
    now <green>active</green>, now <green>active</green> [format string]
      #{FORMATTERS.map { |method, pattern| "<red>#{pattern}</red> #{method}" }.join("\n" + " " * 6)}
  EOF

  def run
    must_exist(self.config.today_path)
    today_list = parse_today_list(self.config)

    active_task = today_list.active_task
    exit 1 unless active_task

    if format_string = @args.shift
      puts(FORMATTERS.reduce(format_string) do |format_string, (method_name, pattern)|
        format_string.gsub(pattern, active_task.send(method_name).to_s)
      end)
    else
      p active_task
    end
  end
end
