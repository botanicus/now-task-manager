require 'pomodoro/router'

class Pomodoro::Commands::Review < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>review</magenta>                                    <bright_black># Journal for today.</bright_black>
    now <magenta>review</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>|<cyan>today</cyan>] <bright_black>   # Review the current time period.</bright_black>
    now <magenta>review</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>|<cyan>today</cyan>] <red.bold>-1</red.bold> <bright_black># Open yesterday's review.</bright_black>
  EOF

  def run
    @date = self.get_date
    router = Pomodoro::Router.new(self.config.data_root_path, @date)
    period = @args.shift

    # TODO: refactor this.
    if period.nil? || period == 'today'
      exec("vim #{self.config.today_path(@date).sub(/\.today$/, '_review.md')}")
    end

    if router.respond_to?(:"#{period}_review_path")
      path = router.send(:"#{period}_review_path")
      command("vim #{path}")
    else
      raise "Unknown period: #{period}"
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
