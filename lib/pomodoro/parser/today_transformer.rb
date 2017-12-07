require 'parslet'
require 'pomodoro/exts/hour'
require 'pomodoro/task'
require 'pomodoro/time_frame'

module Pomodoro
  class TodayTransformer < Parslet::Transform
    STATUS_MAPPING ||= {
      finished: ['✓', '✔', '☑'],
      failed:   ['✕', '☓', '✖', '✗', '✘', '☒'],
      wip:      ['☐', '⛶', '⚬']
    }

    rule(desc: simple(:desc)) {
      {desc: desc.to_s.strip}
    }

    rule(duration: simple(:duration)) {
      {duration: Integer(duration)}
    }

    rule(hour: simple(:hour_string)) {
      Hour.parse(hour_string.to_s)
    }

    rule(tag: simple(:tag)) {
      {tag: tag.to_sym}
    }

    rule(indent: simple(:char)) {
      status, _ = STATUS_MAPPING.find { |status, i| i.include?(char) }
      status ? {status: status} : Hash.new
    }

    rule(task: subtree(:hashes)) {
      data = hashes.reduce(Hash.new) do |buffer, hash|
        key = hash.keys.first
        if buffer.has_key?(key)
          buffer.merge(key => [buffer[key], hash[key]].flatten)
        else
          buffer.merge(hash)
        end
      end

      if data[:tag]
        data[:tags] = [data.delete(:tag)].flatten
      end

      if data[:line]
        data[:lines] = [data.delete(:line)].flatten
      end

      begin
        Pomodoro::Task.new(**data)
      rescue ArgumentError => error
        message = [error.message, "Arguments were: #{data.inspect}"].join("\n")
        raise ArgumentError.new(message)
      end
    }

    rule(time_frame: subtree(:data)) {
      data[:desc] = data[:desc].to_s.strip # WTH? All the other nodes are processed correctly?
      Pomodoro::TimeFrame.new(**data)
    }
  end
end
