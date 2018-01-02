# # Activities
#
# - Tap class.
# - Spanish meetup.

module Pomodoro::Formats::Review::Plugins::Activities
  HEADER ||= 'Activities'

  def self.parse(string)
    tree = Parser.new.parse(string)
    nodes = Transformer.new.apply(tree)
    Expenses.new(nodes.empty? ? Array.new : nodes)
  end

  class Parser < Parslet::Parser
    # TODO
  end

  class Transformer < Parslet::Transform
    # TODO
  end
end

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::Activities)
