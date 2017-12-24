class Pomodoro::Commands::Review < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>review</magenta> [year|quarter|month|week]<bright_black># ...</bright_black>
  EOF

  def run
    case @args.shift
    when 'year'
      command("vim #{config.data_root_path(Date.today.year, 'year.review')}")
    else
      raise "Not done yet."
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
