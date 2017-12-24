class Pomodoro::Commands::Postpone < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>postpone</magenta> <bright_black># Postpone the active task.</bright_black>
  EOF

  def run
    ensure_today

    if  with_active_task(self.config) do |active_task|
          print "<bold>Why?</bold> "
          reason = $stdin.readline.chomp
          print "<bold>When do you want to review?</bold> Defaults to tomorrow. Format <yellow>%d/%m</yellow> "
          review_at = $stdin.readline.chomp

          if review_at.empty?
            review_date = active_task.postpone!(reason)
          else
            review_date = Date.strptime(review_at, '%d/%m')
            review_date = active_task.postpone!(reason, review_date)
          end

          puts "<bold>~</bold> <green>#{unsentence(active_task.body)}</green> has been postponed to <yellow>#{review_date.strftime('%-d/%-m')}</yellow>."
        end
    else
      abort "<red>There is no task in progress.</red>"
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end
end
