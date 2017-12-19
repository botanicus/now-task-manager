class Pomodoro::Commands::GenerateUpcomingEvents < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now generate-upcoming-events<bright_black># ...</bright_black>
  EOF

  def run
    require 'date'

    upcoming_events = self.config.calendar.select do |event_name, date|
      ((Date.today + 1)..(Date.today + 8)).include?(date)
    end

    unless upcoming_events.empty?
      # TODO: create new if no File.exist?(self.config.task_list_path)
      task_list = parse_task_list(self.config)
      upcoming_events.each do |event_name, date|
        puts "~ Adding #{event_name} for #{date.strftime('%A %d/%m')}."
        if task_group = task_list[date.strftime('%A')]
          task_group << event_name
        else
          task_list << Pomodoro::Formats::Scheduled::TaskGroup.new(date.strftime('%A'), [event_name])
        end
      end

      task_list.save(self.config.task_list_path)
    end
  end
end
