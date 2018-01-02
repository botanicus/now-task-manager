require 'parslet'
require 'pomodoro/formats/review'

module Pomodoro::Formats::Review
  # @api private
  class Parser < Parslet::Parser
    rule(:header) {
      str('# ') >> (str("\n").absent? >> any).repeat(1).as(:header) >> str("\n")
    }

    rule(:data) {
      (header.absent? >> any).repeat.as(:data)
    }

    rule(:section) {
      header >> data
    }

    rule(:sections) {
      section.as(:section).repeat
    }

    root(:sections)
  end
end
