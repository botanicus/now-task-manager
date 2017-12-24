class Pomodoro::Commands::Review < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>review</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>] <bright_black># Review the current time period.</bright_black>
  EOF

  def week_review_path
    self.config.data_root_path(@date.year, @date.month, "week-#{@date.cweek}.review")
  end

  def month_review_path
    self.config.data_root_path(@date.year, @date.month, 'month.review')
  end

  def quarter_review_path
    quarter = (@date.month / 4) + 1
    self.config.data_root_path(@date.year, "Q#{quarter}.review")
  end

  def year_review_path
    self.config.data_root_path(@date.year, 'year.review')
  end

  def run
    @date = Date.today
    period = @args.shift
    if self.respond_to?(:"#{period}_review_path")
      path = self.send(:"#{period}_review_path")
      command("vim #{path}")
    else
      raise "Unknown period: #{period}"
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
