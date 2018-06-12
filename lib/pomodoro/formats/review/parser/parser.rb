# frozen_string_literal: true

require 'parslet'
require 'pomodoro/formats/review'

module Pomodoro::Formats::Review
  # @api private
  class Parser < Parslet::Parser
    rule(:header) do
      str('# ') >> (str("\n").absent? >> any).repeat(1).as(:str) >> str("\n")
    end

    rule(:raw_data) do
      (header.absent? >> any).repeat.as(:str)
    end

    rule(:section) do
      header.as(:header) >> raw_data.as(:raw_data)
    end

    rule(:sections) do
      section.as(:section).repeat
    end

    root(:sections)
  end
end
