class Pomodoro::Commands::Plan < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>plan</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>] <bright_black># Plan the coming time period.</bright_black>
  EOF

  def week_plan_path
    if Date.new(@date.year, 12, 31).cweek == @date.cweek
      # self.config.data_root_path(@date.year + 1, 1, "week-1.plan")
      self.config.data_root_path(@date.year + 1, 'features', 'weeks', '1.plan')
    else
      monday_next_week = Date.new(@date.year, 1, 1) + (@date.cweek * 7) + 1
      # self.config.data_root_path(@date.year, monday_next_week.month, "week-#{monday_next_week.cweek}.plan")
      self.config.data_root_path(@date.year, 'features', 'weeks', "#{monday_next_week.cweek}.plan")
    end
  end

  def month_plan_path
    if @date.month == 12
      year, month = @date.year + 1, 1
    else
      year, month = @date.year, @date.month + 1
    end

    # self.config.data_root_path(year, month, 'month.plan')
    self.config.data_root_path(year, 'features', 'months', "#{month}.feature")
  end

  def quarter_plan_path
    # coming_quarter = (@date.month / 4) + 2
    # if coming_quarter == 5
    #   self.config.data_root_path(@date.year + 1, "Q1.plan")
    # else
    #   self.config.data_root_path(@date.year, "Q#{coming_quarter}.plan")
    # end
    coming_quarter = (@date.month / 4) + 2
    if coming_quarter == 5
      self.config.data_root_path(@date.year + 1, 'features', 'Q1.feature')
    else
      self.config.data_root_path(@date.year, 'features', "Q#{coming_quarter}.feature")
    end
  end

  def year_plan_path
    # self.config.data_root_path(@date.year + 1, 'year.plan')
    year = @date.year + 1
    self.config.data_root_path(year, 'features', "#{year}.feature")
  end

  def run
    @date = Date.today
    period = @args.shift
    root_dir = self.config.data_root_path(@date.year, 'features') ### This is imprecise.

    if self.respond_to?(:"#{period}_plan_path")
      path = self.send(:"#{period}_plan_path")
      unless File.directory?(root_dir)
        abort "<red>Features</red> in #{Pomodoro::Tools.format_path(root_dir)} are not initialised."
      end

      Dir.chdir(root_dir) do
        unless File.directory?(File.dirname(path))
          command("mkdir -p #{File.dirname(path)}")
        end

        command("vim #{path}")
      end
    else
      raise "Unknown period: #{period}"
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
