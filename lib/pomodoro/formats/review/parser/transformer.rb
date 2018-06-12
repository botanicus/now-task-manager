# frozen_string_literal: true

require 'parslet'
require 'pomodoro/formats/review'

module Pomodoro::Formats::Review
  # @api private
  class Transformer < Parslet::Transform
    rule(str: simple(:slice)) { slice.to_s.strip }
    rule(str: sequence(:slice)) { slice.empty? ? '' : slice }

    rule(section: subtree(:data)) do
      Section.new(**data)
    end
  end
end
