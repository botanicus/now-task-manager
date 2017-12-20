class Pomodoro::Commands::Log < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>log</green> key=value key=value <bright_black># ...</bright_black>
    now <green>log</green> weight=69.6
    now <green>log</green> 'expense=Lunch at Parniczek' cost=14
  EOF

  def run
    if @args.empty?
      abort "<red>Usage:</red> now log key=value key=value".colourise
    end

    must_exist(self.config.today_path)

    data = @args.reduce(Hash.new) do |hash, pair_string|
      key, value = pair_string.split('=')
      hash.merge(key => value)
    end

    item = Pomodoro::Formats::Today::LogItem.new(data)

    time_frame do |today_list, current_time_frame|
      current_time_frame.items << item
      today_list.save(config.today_path)
    end
  end
end
