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
    # Doesn't work BECAUSE it has multiple keys.
    # Maybe refactor to do {str: 'x'}
    rule(body: simple(:body)) { body.to_s }

    rule(header: simple(:header)) { header.to_s }

    rule(hour: simple(:hour_string)) do
      Hour.parse(hour_string.to_s)
    end

    rule(tags: subtree(:tags)) do
      tags.map { |tag| tag[:tag].to_sym }
    end

    rule(task: subtree(:data)) do
      options = {
        time_frame: data[:time_frame] ? nil : data[:time_frame].to_s,
        start_time: data[:start_time],
        body: data[:body].to_s.strip,
        tags: data[:tags].map { |tag| tag[:tag].to_sym }
      }

      Task.new(**options)
    end

    rule(task_group: subtree(:task_group)) {
      options = {
        header: task_group[:header].to_s,
        tasks:  task_group[:task_list]
      }

      TaskGroup.new(**options)
    }
  end
end
