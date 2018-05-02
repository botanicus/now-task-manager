# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Console < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <yellow>console</yellow> <bright_black># #{self.description}</bright_black>
    Available variables (use <bold>ls</bold> to display them):
    active_task  archive  config current_time_frame  tasks  today
  EOF

  def run
    require 'pomodoro/formats/today/archive'

    if File.exist?(self.config.today_path)
      # This way we don't get the path.
      today = Pomodoro::Formats::Today.parse(File.read(self.config.today_path, encoding: 'utf-8'))
    end

    if File.exist?(self.config.task_list_path)
      tasks = parse_task_list(self.config)
    end

    beginning_of_the_month = Date.new(Date.today.year, Date.today.month, 1)
    archive = Pomodoro::Formats::Today::Archive.new(beginning_of_the_month, Date.today)

    config

    current_time_frame = today.task_list.current_time_frame
    active_task = today.task_list.active_task

    # Run ls to see the list of the local variables.
    require 'pry'; binding.pry
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
