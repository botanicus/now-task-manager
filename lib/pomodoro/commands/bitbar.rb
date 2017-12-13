require 'pomodoro/exts/hour'

module Pomodoro
  module Commands
    class BitBar
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
        if current_time_frame
          if current_time_frame.end_time
            puts "#{current_time_frame.start_time}-#{current_time_frame.end_time} (#{current_time_frame.remaining_duration}h remaining) | color=green"
          else
            puts "After #{current_time_frame.start_time} | color=gray"
          end
          current_time_frame.tasks.each do |task|
            if task.fixed_start_time
              puts "#{task.fixed_start_time} #{task.body.chomp} | color=red"
            else
              hash = {unstarted: 'blue', in_progress: 'red'}
              hash.default_proc = Proc.new { 'gray' }
              colour = hash[task.status_x]
              puts "#{task.body.chomp} | color=#{colour}"
            end

            if task.in_progress?
              puts "-- Finish   | bash='now done'     color=black"
              puts "-- Postpone | bash='now postpone' color=black"
              puts "-- Move on  | bash='now move_on'  color=black"
              $ACTIVE_TASK = true
            end

            if current_time_frame.first_unstarted_task == task && ! $ACTIVE_TASK
              puts "-- Start | bash='now start' color=black"
            end
          end
        elsif Time.now.hour < 14
          today_tasks.each do |time_frame|
            task_lines = time_frame.to_s.split("\n")[1..-1]
            puts "#{time_frame.header} | color=#{task_lines.empty? ? 'gray' : 'green'}"
            task_lines.each do |line|
              colour = {not_done: 'black', done: 'gray', failed: 'black'}[task.status]
              puts "#{line.gsub(/^- /, '-- ')} | color=#{colour}"
            end
          end
          puts "Total: XYZ | colour=gray"
        else
          puts "Hours worked: #{Hour.new(0, today_tasks.duration)}"
        end
      end

      def self.main(today_tasks, task_list)
        if today_tasks && current_time_frame = today_tasks.current_time_frame
          colour, icon = self.heading(current_time_frame)
          puts icon, '---'
          self.with_active_time_frame(current_time_frame)
        elsif today_tasks
          colour, icon = self.heading(nil)
          puts icon, '---'
          puts 'TODO: Some day summary and possibly show tomorrow.'
        else
          colour, icon = self.heading(nil)
          puts icon, '---'
          puts "Run 'pomodoro e' to add some tasks. | color=green"
        end

        if task_list && task_list.any? { |task_group| ! task_group.tasks.empty? }
          puts '---', "Scheduled tasks"
          task_list.each do |task_group|
            unless task_group.tasks.empty?
              colour = if task_group.scheduled_date == (Date.today + 1)
                'red'
              elsif task_group.scheduled_date.nil? || ! task_group.header == 'Later' # TODO: Fix later being blue.
                'blue' # Context.
              elsif ((Date.today + 1)..(Date.today + 4)).include?(task_group.scheduled_date)
                'black'
              else
                'gray'
              end
              puts "-- #{task_group.header} | color=#{colour}"
              task_group.tasks.each do |task|
                # TODO: After the parser is updated: task.fixed_start_time
                puts "---- #{task} | color=#{task.to_s.match(/\[\d+:\d+\]/) ? 'red': 'black'}"
              end
            end
          end
        end
      end
    end
  end
end
