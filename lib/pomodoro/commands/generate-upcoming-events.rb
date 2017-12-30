require 'date'

class Pomodoro::Commands::GenerateUpcomingEvents < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <blue>generate-upcoming-events</blue> <bright_black># ...</bright_black>
  EOF

  def run
    upcoming_events = self.config.calendar.select do |event_name, date|
      ((Date.today + 1)..(Date.today + 8)).include?(date)
    end

    unless upcoming_events.empty?
      # TODO: create new if no File.exist?(self.config.task_list_path)
      task_list = parse_task_list(self.config)
      upcoming_events.each do |event_name, date|
        puts t(:adding, event: event_name, date: date.strftime('%A %d/%m'))
        if task_group = task_list[date.strftime('%A')]
          task_group << event_name
        else
          task_list << Pomodoro::Formats::Scheduled::TaskGroup.new(date.strftime('%A'), [event_name])
        end
      end

      task_list.save(self.config.task_list_path)
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
