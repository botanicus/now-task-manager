# frozen_string_literal: true

require 'parslet'
require 'refined-refinements/hour'
require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class Transformer < Parslet::Transform
    STATUS_MAPPING ||= {
      finished: ['✓', '✔', '☑'],
      failed:   ['✕', '☓', '✖', '✗', '✘', '☒'],
      wip:      ['☐', '⛶', '⚬']
    }.freeze

    rule(str: simple(:slice)) { slice.to_s.strip }

    rule(tag: simple(:slice)) { slice.to_sym }

    rule(hour: simple(:hour_string)) do
      Hour.parse(hour_string.to_s)
    end

    # This might to get matched(?)
    rule(duration: simple(:duration)) do
      {duration: Hour.new(0, Integer(duration))}
    end

    # This doesn't get matched because there are multiple keys in the hash.
    rule(indent: simple(:char)) do
      status, = Task::STATUS_MAPPING.find { |status, i| i.include?(char) }
      {status: status}
    end

    rule(task: subtree(:data)) do
      char = data.delete(:indent)
      status, = Task::STATUS_MAPPING.find { |status, i| i.include?(char) }
      data[:status] = status

      if duration = data.delete(:duration)
        data[:duration] = Hour.new(0, Integer(duration))
      end

      begin
        Task.new(**data)
      rescue ArgumentError => error
        message = [error.message, "Arguments were: #{data.inspect}"].join("\n")
        raise ArgumentError, message
      end
    end

    rule(time_frame: subtree(:data)) do
        TimeFrame.new(**data)
    rescue ArgumentError => error
        message = [error.message, "Arguments were: #{data.inspect}"].join("\n")
        raise ArgumentError, message
    end
  end
end
