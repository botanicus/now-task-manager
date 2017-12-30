class Pomodoro::Commands::Add < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <red>+</red> [strings]<bright_black> # #{self.description}</bright_black>
  EOF

  def run
    task_list = parse_task_list(self.config)

    task = Pomodoro::Formats::Scheduled::Task.new(body: @args.join(' '))
    task_list['Later'] || task_list << Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Later')
    task_list['Later'] << task

    task_list.save(self.config.task_list_path)
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
