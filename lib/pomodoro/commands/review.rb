require 'pomodoro/router'

class Pomodoro::Commands::Review < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>review</magenta>                                    <bright_black># Journal for today.</bright_black>
    now <magenta>review</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>|<cyan>day</cyan>] <bright_black>   # Review the current time period.</bright_black>
    now <magenta>review</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>|<cyan>day</cyan>] <red.bold>-1</red.bold> <bright_black># Open yesterday's review.</bright_black>
  EOF

  def run
    period, date = self.get_period_and_date(:day)
    router = Pomodoro::Router.new(self.config.data_root_path, date)

    abort t(:cannot_be_past_today) if date > Date.today

    router = Pomodoro::Router.new(self.config.data_root_path, date)

    # TODO: refactor this.
    if period.nil? || period == :day
      exec("vim #{self.config.today_path(date).sub(/\.today$/, '_review.md')}")
    end

    if router.respond_to?(:"#{period}_review_path")
      path = router.send(:"#{period}_review_path")
      command("vim #{path}")
    else
      raise t(:unknown_period, period: period)
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
