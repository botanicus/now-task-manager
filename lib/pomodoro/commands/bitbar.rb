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
    end
  end
end