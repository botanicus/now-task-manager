class Pomodoro::Commands::Console < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <yellow>console</yellow>, now <yellow>c</yellow> <bright_black># Load the tasks and launch IRB.</bright_black>
  EOF

  def run
    require 'pomodoro/formats/today/archive'

    today   = parse_today_list(self.config) if File.exist?(self.config.today_path)
    tasks   = parse_task_list(self.config)  if File.exist?(self.config.task_list_path)
    archive = Pomodoro::Formats::Today::Archive.new(Date.new(2017, 12, 3), Date.today)
    config

    require 'pry'; binding.pry
  end
end
