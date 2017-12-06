require 'parslet'
require 'pomodoro/exts/hour'
require 'pomodoro/task'
require 'pomodoro/time_frame'

module Pomodoro
  class ObjectTransformer < Parslet::Transform
    STATUS_MAPPING ||= {
      finished: ['✓', '✔', '☑'],
      failed:   ['✕', '☓', '✖', '✗', '✘', '☒'],
      wip: ['☐', '⛶', '⚬']
    }

    rule(hour: simple(:hour_string)) {
      Hour.parse(hour_string.to_s)
    }

    rule(indent: simple(:char)) {
      status, _ = STATUS_MAPPING.find { |status, i| i.include?(char) }
      status ? {status: status} : Hash.new
    }

    rule(task: subtree(:hashes)) {
      data = hashes.reduce(Hash.new) { |buffer, hash| buffer.merge(hash) }

      Pomodoro::Task.new(**data)
    }

    rule(time_frame: subtree(:data)) {
      Pomodoro::TimeFrame.new(**data)
    }
  end
end
