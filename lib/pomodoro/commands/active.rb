class Pomodoro::Commands::Active < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>active</green> <bright_black># Print the active task.</bright_black>
  EOF

  def run
    unless File.exist?(self.config.today_path)
      abort "<red>! File #{self.config.today_path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
    end

    today_list = parse_today_list(self.config)
    if  active_task = today_list.active_task
      case ARGV.shift
       # git-commit-pomodoro
       # TODO: Subtasks as well.
      when 'git'    then puts active_task.text
      when 'prompt' then puts active_task.text
      when nil      then puts active_task
      else
        puts 'xxx'
        # TODO: Format with %d etc.
      end
    else
      abort "<red>No active tasks.</red>".colourise
    end
  end
end
