require 'parslet'
require 'pomodoro/formats/scheduled'

module Pomodoro::Formats::Scheduled
  class Task
    attr_reader :start_time, :time_frame, :body, :tags
    def initialize(start_time: nil, time_frame: nil, body:, tags: Array.new)
      @start_time, @time_frame, @body, @tags = start_time, time_frame, body, tags
    end

    def to_s
      [
        '-',
        ("[#{@time_frame}]" if @time_frame),
        ("[#{@start_time}]" if @start_time),
        "#{@body}", *@tags.map { |tag| "##{tag}"}
      ].compact.join(' ')
    end
  end

  # @api private
  class Transformer < Parslet::Transform
    rule(str: simple(:slice)) { slice.to_s.strip }

    rule(tag: simple(:slice)) { slice.to_sym }

    rule(hour: simple(:hour_string)) do
      Hour.parse(hour_string.to_s)
    end

    rule(task: subtree(:data)) do
      Task.new(**data)
    end

    rule(task_group: subtree(:data)) {
      TaskGroup.new(**data)
    }
  end
end
