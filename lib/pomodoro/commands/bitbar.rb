class Pomodoro::Commands::BitBar < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <yellow>bitbar</yellow> <bright_black># Print output for BitBar.</bright_black>
  EOF

  def run
    today_list = parse_today_list(self.config) if File.exist?(self.config.today_path)
    task_list  = parse_task_list(self.config)  if File.exist?(self.config.task_list_path)
    Pomodoro::Commands::BitBarUI.main(today_list, task_list)
  end
end

class Pomodoro::Commands::BitBarUI
  def self.heading(current_time_frame)
    if current_time_frame
      self.heading_work_in_progress(current_time_frame)
    else
      ['black', self.heading_default_icon]
    end
  end

  def self.heading_default_icon
    "| image=iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAACx1BMVEUAAAAhZ5QmerEmgLkmgLomgLomgLomgLomgLomgLkme7EhZ5QAAAAeYYwlerIcWogZTHkaTn0aTn0aTn0aTn0aTn0aTXocW4klerIfYYwicaUaZJtRXGurrLCur7NWYW4aZZoicaUhcacUWpN7hZWCi5gWXJQhcKcebqUTWZN9h5eDjJsUW5UebqUca6QRV5N8h5eDjJoSWZQca6QaaKMPVZJ8h5eDjJoQV5QaaKMXZqINU5F8h5eDjJoPVZMXZqIVY6AMUZB8h5eDjJoNU5IVY6ETX58LTo98h5eDjJoMUJATX58SXJwKTI18h5eDjJoLTo8SXJwRWJoJSYx9h5eDjJoKS40RWJsQVJcKSYx/iJeBipcKSY0QVJcORHwNU50yUnlVaYZTaIVTaIVTaIVTaIVTaIVUaIUwUXcNU50ORH0GGzENRH8LUZ0JUKAJUaEJUaEJUaEJUaEJUaEJUKALUZ4NRH8GHDIAAAADDBcIJUYILFQILFQILFQILFQILFQILFQILFQIJUYDDRgAAACxs7ewsrewsrewsrexs7f29fT19PT09PT09PT09PT09PT29fX39vb39vX19PPy8vLy8vLy8vLy8vL09PTf39/Jycny8fD19PPy8vLz8/Py8vLy8vLy8vK1tbVeXl6wsLD19fT19PPq6ura2trz8/Py8vKlpaVISEisrKzy8vL19fT29vXS0tJeXl60tLS0tLRFRUWlpaX09PTy8vL19PT19PPx8fGfn59JSUlISEiGhobv7+/z8/Py8vL19PT19PPz8/Pu7u6Pj49lZWXd3d309PTy8vLy8vL19PT19PPy8vLz8/Pl5eXMzMzy8vLy8vLy8vLy8vL19PT19PPy8vLy8vLz8/P09PTy8vLy8vLy8vLy8vL19fTz8e/v7u3v7u3v7u3v7u3v7u3v7u3v7u3v7u3y8e////+EY5Z8AAAAhXRSTlMDW8nf3t7e3t7fylwESeT////////////lS5b///////+YpP////+kpP////+kpP////+kpP////+kpP////+kpP////+kpP////+kpP////+kpP////+ko/////+jhf7////////////+hi3A+/7+/v7+/v77wi8AMomjpKSkpKSjiTMB0B5+TQAAAAFiS0dE7CG5sxsAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQfhAhQRBSmWVlRBAAABG0lEQVQY0wEQAe/+AAABAgMEBQYGBgYHCAkKCwwADQ4PEBESExMTExQVFhcYGQAaGxwdhYaHh4eHiIkeHyAhACIjJIqLjI2Njo+QkZIlJicAKCkqk5SVlZaXmJmamyssLQAuLzCcnZ6foKGio6SlMTIzADQ1NqanqKmqq6ytrq83ODkAOjs8sLGys7S1tre4uT0+PwBAQUK6u7y9vr/AwcLDQ0RFAEZHSMTFxsfIycrLzM1JSksATE1Ozs/Q0dLT1NXW109QUQBSU1TY2drb3N3e3+DhVVZXAFhZWuLj5OXm5+jp6utbXF0AXl9gYWJjZGRkZGVmZ2hpagBrbG1ub3BxcXFxcnN0dXZ3AHh5ent8fX5+fn5/gIGCg4Sov3NOEAy3KQAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNy0wMi0yMFQxNzowNTo0MS0wNTowMHrHzbIAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTctMDItMjBUMTc6MDU6NDEtMDU6MDALmnUOAAAAAElFTkSuQmCC"
  end

  def self.heading_work_in_progress(current_time_frame)
    colour = self.colour_based_on_remaining_duration(current_time_frame)
    [colour, "#{current_time_frame.name} | color=#{colour}"]
  end

  def self.colour_based_on_remaining_duration(current_time_frame)
    if current_time_frame.remaining_duration.nil?
      'gray'
    elsif current_time_frame.remaining_duration < Hour.new(0, 10)
      'red'
    elsif current_time_frame.remaining_duration < Hour.new(0, 30)
      'blue'
    else
      'green'
    end
  end

  def self.with_active_time_frame(current_time_frame)
    puts "#{current_time_frame.header} | color=green"
    puts "#{current_time_frame.remaining_duration}h remaining"

    current_time_frame.tasks.each do |task|
      if task.fixed_start_time && ! task.ended? && ! task.started?
        puts "#{task.fixed_start_time} #{task.body.chomp} | color=red"
      end

      if task.in_progress?
        puts "#{task.body.chomp} | color=blue"
        # We don't have support for having both start/end time and duration #31.
        # if task.duration
        #   print " #{task.remaining_duration(current_time_frame)}"
        # end
        puts "-- Finish   | bash='now done'     color=black"
        puts "-- Postpone | bash='now postpone' color=black"
        puts "-- Move on  | bash='now move_on'  color=black"
        $ACTIVE_TASK_PRESENT = true
      elsif current_time_frame.first_unstarted_task == task && ! $ACTIVE_TASK_PRESENT
        puts "#{task.body.chomp} | color=blue"
        puts "-- Start | bash='now start' color=black"
      else
        puts "#{task.body.chomp} | color=gray"
      end
    end
  end

  def self.show_upcoming_time_frames(today_tasks, current_time_frame)
    index = today_tasks.time_frames.index(current_time_frame)
    upcoming_time_frames = today_tasks.time_frames[(index + 1)..-1]

    unless upcoming_time_frames.empty?
      puts '---'
      puts "Rest of the today's schedule | color=green"
      upcoming_time_frames.each do |upcoming_time_frame|
        puts "#{upcoming_time_frame.header} | color=black"
      end
    end
  end

  def self.main(today_tasks, task_list)
    if today_tasks && current_time_frame = today_tasks.current_time_frame
      colour, icon = self.heading(current_time_frame)
      puts icon, '---'
      self.with_active_time_frame(current_time_frame)
      self.show_upcoming_time_frames(today_tasks, current_time_frame)
    elsif today_tasks
      colour, icon = self.heading(nil)
      puts icon, '---'
      puts 'TODO: Some day summary and possibly show tomorrow.' #33
    else
      colour, icon = self.heading(nil)
      puts icon, '---'
      puts "Click here to add some tasks. | bash='now edit' color=green"
    end

    if task_list && task_list.any? { |task_group| ! task_group.tasks.empty? }
      puts '---', "Scheduled tasks"
      task_list.each do |task_group|
        unless task_group.tasks.empty?
          colour = if task_group.scheduled_date == (Date.today + 1)
            'green'
          elsif task_group.scheduled_date.nil? && task_group.header != 'Later'
            'blue' # Context.
          elsif ((Date.today + 1)..(Date.today + 4)).include?(task_group.scheduled_date)
            'black'
          else
            'gray'
          end
          puts "-- #{task_group.header} | color=#{colour}"
          task_group.tasks.each do |task|
            # After the parser is updated: task.fixed_start_time #32
            puts "---- #{task} | color=#{task.to_s.match(/\[\d+:\d+\]/) ? 'red': 'black'}"
          end
        end
      end
    end
  end
end
