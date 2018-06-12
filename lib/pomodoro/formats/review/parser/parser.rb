# frozen_string_literal: true

require 'parslet'
require 'pomodoro/formats/review'

module Pomodoro::Formats::Review
  # @api private
  class Parser < Parslet::Parser
    rule(:header) {
      str('# ') >> (str("\n").absent? >> any).repeat(1).as(:str) >> str("\n")
    }

    rule(:raw_data) {
      (header.absent? >> any).repeat.as(:str)
    }

    rule(:section) {
      header.as(:header) >> raw_data.as(:raw_data)
    }

    rule(:sections) {
      section.as(:section).repeat
    }

    root(:sections)
  end
end
