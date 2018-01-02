# ```markdown
# # Consumption
#
# 1.9 Tequila 35% 1.5 shots.
# 2.3 Glass of wine.
# ```

module Pomodoro::Formats::Review::Plugins::Consumption
  HEADER ||= 'Consumption'

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

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::Consumption)
