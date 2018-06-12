# frozen_string_literal: true

# TODO: Rethink plan & test (do we really want to use features)?
# https://github.com/botanicus/now-task-manager/issues/122
require 'pomodoro/router'

class Pomodoro::Commands::Plan < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>plan</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>] <bright_black># Plan the coming time period.</bright_black>
    now <magenta>plan</magenta> -1 [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>] <bright_black># Open plan for the current time period.</bright_black>
  EOF

  def run
    period, date = self.get_period_and_date(:week)
    router = Pomodoro::Router.new(self.config.data_root_path, date)

    if router.respond_to?(:"#{period}_plan_path")
      path = router.send(:"#{period}_plan_path")
      unless router.features_path.directory?
        abort t(:not_initialised, path: RR::Homepath.new(router.features_path.to_s))
      end

      Dir.chdir(router.features_path.to_s) do
        unless File.directory?(File.dirname(path))
          command("mkdir -p #{File.dirname(path)}")
        end

        command("nvim #{path}")
      end
    else
      abort t(:unknown_period, period: period)
    end
  end
end
