# frozen_string_literal: true

module Pomodoro::Formats::Today
  class Formatter
    def self.format(task)
      output = [task.class::STATUS_MAPPING[task.status][0]]
      if task.start_time || task.end_time
        output << "[#{self.format_duration(task.start_time, task.end_time)}]"
      end
      output << "[#{task.fixed_start_time}]" if task.fixed_start_time
      output << "[#{task.duration.minutes}]" if task.duration
      output << task.body
      output << task.tags.map { |tag| "##{tag}" }.join(' ') unless task.tags.empty?
      main_line = output.join(' ') + "\n"
      if task.lines.empty?
        main_line
      else
        main_line + task.lines.map { |line| "  #{line}" }.join("\n") + "\n"
      end
    end

    def self.format_duration(start_time, end_time)
      if start_time && end_time
        [start_time, end_time].join('-')
      elsif start_time
        "#{start_time}-????"
      elsif end_time
        raise 'nonsense' # FIXME: now next-done should in fact note the time.
      end
    end
  end
end
