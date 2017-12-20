require 'parslet'
require 'pomodoro/exts/hour'
require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class Transformer < Parslet::Transform
    STATUS_MAPPING ||= {
      finished: ['✓', '✔', '☑'],
      failed:   ['✕', '☓', '✖', '✗', '✘', '☒'],
      wip:      ['☐', '⛶', '⚬']
    }

    rule(str: simple(:slice)) { slice.to_s.strip }

    rule(tag: simple(:slice)) { slice.to_sym }

    rule(hour: simple(:hour_string)) {
      Hour.parse(hour_string.to_s)
    }

    # This might to get matched(?)
    rule(duration: simple(:duration)) {
      {duration: Hour.new(Integer(duration))}
    }

    # This doesn't get matched because there are multiple keys in the hash.
    rule(indent: simple(:char)) {
      status, _ = Task::STATUS_MAPPING.find { |status, i| i.include?(char) }
      {status: status}
    }

    rule(log_item: simple(:blob)) {
      hash = blob.to_s.chomp('.').split(/, /).reduce(Hash.new) do |buffer, chunk|
        key, value = chunk.split(': ')
        buffer.merge(key => value)
      end

      begin
        LogItem.new(hash)
      rescue ArgumentError => error
        message = [error.message, "Arguments were: #{data.inspect}"].join("\n")
        raise ArgumentError.new(message)
      end
    }

    rule(task: subtree(:data)) {
      char = data.delete(:indent)
      status, _ = Task::STATUS_MAPPING.find { |status, i| i.include?(char) }
      data[:status] = status

      begin
        Task.new(**data)
      rescue ArgumentError => error
        message = [error.message, "Arguments were: #{data.inspect}"].join("\n")
        raise ArgumentError.new(message)
      end
    }

    rule(time_frame: subtree(:data)) {
      begin
        TimeFrame.new(**data)
      rescue ArgumentError => error
        message = [error.message, "Arguments were: #{data.inspect}"].join("\n")
        raise ArgumentError.new(message)
      end
    }
  end
end
