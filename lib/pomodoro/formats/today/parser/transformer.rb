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

    rule(body: simple(:body)) {
      {body: body.to_s.strip}
    }

    rule(name: simple(:name)) {
      {name: desc.to_s.strip}
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
      status, _ = Task::STATUS_MAPPING.find { |status, i| i.include?(char) }
      {status: status}
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
        Task.new(**data)
      rescue ArgumentError => error
        message = [error.message, "Arguments were: #{data.inspect}"].join("\n")
        raise ArgumentError.new(message)
      end
    }

    rule(tags: subtree(:data)) {
      data.map { |h| h[:tag] }
    }

    rule(time_frame: subtree(:data)) {
      data[:name] = data.delete(:name).to_s.strip # WTH? All the other nodes are processed correctly?
      begin
        TimeFrame.new(**data)
      rescue ArgumentError => error
        message = [error.message, "Arguments were: #{data.inspect}"].join("\n")
        raise ArgumentError.new(message)
      end
    }
  end
end
