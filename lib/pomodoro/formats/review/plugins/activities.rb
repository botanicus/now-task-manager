# frozen_string_literal: true

# # Activities
#
# - Tap class.
# - Spanish meetup.

module Pomodoro::Formats::Review::Plugins::Activities
  HEADER ||= 'Activities'

  def self.parse(string)
    tree = Parser.new.parse(string)
    nodes = Transformer.new.apply(tree)
    nodes.empty? ? Array.new : nodes
  end

  class Parser < Parslet::Parser
    rule(:node) do
      str('- ') >> (str("\n").absent? >> any).repeat.as(:str) >> str("\n")
    end

    rule(:nodes) do
      node.repeat
    end

    root(:nodes)
  end

  class Transformer < Parslet::Transform
    rule(str: simple(:slice)) { slice.to_s.strip }
  end
end

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::Activities)
