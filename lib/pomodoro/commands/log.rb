class Pomodoro::Commands::Log < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>log</green> key=value key=value <bright_black># ...</bright_black>
    now <green>log</green> weight=69.6
    now <green>log</green> 'expense=Lunch at Parniczek' cost=14
  EOF

  def run
    warn "<bold>~</bold> <yellow>This functionality might be removed.</yellow>"

    if @args.empty?
      abort "<red>Usage:</red> now log key=value key=value"
    end

    ensure_today

    data = @args.reduce(Hash.new) do |hash, pair_string|
      key, value = pair_string.split('=')
      hash.merge(key => value)
    end

    item = Pomodoro::Formats::Today::LogItem.new(data)

    time_frame do |today_list, current_time_frame|
      current_time_frame.items << item
      day.save(config.today_path)
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
