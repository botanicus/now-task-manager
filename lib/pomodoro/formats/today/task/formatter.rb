module Pomodoro::Formats::Today
  class Formatter
    def self.format(task)
      output = [task.class::STATUS_MAPPING[task.status][0]]
      if task.start_time || task.end_time
        output << "[#{task.format_interval(task.start_time, task.end_time)}]"
      else
        output << "[#{task.duration}]" if task.duration
      end
      output << task.body
      output << task.tags.map { |tag| "##{tag}"}.join(' ') unless task.tags.empty?
      output.join(' ') + "\n"
    end
  end
end
