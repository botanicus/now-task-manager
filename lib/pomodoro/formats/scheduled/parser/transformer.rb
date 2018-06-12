# frozen_string_literal: true

require 'parslet'
require 'refined-refinements/hour'
require 'pomodoro/formats/scheduled'

module Pomodoro::Formats::Scheduled
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
