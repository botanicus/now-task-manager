# frozen_string_literal: true

# ```markdown
# # Consumption
#
# 1.9 Tequila 35% 1.5 shots.
# 2.3 Glass of wine.
# ```

# TODO:
# Add totals:
# 1.9 Tequila 35% 1.5 shots.
# 2.3 Glass of wine.
# Total: 4.2
#
# Don't parse it, it'd be updated from the data.
module Pomodoro::Formats::Review::Plugins::Consumption
  HEADER ||= 'Consumption'

  def self.parse(string)
    tree = Parser.new.parse(string)
    nodes = Transformer.new.apply(tree)
    ConsumptionItems.new(nodes.empty? ? Array.new : nodes)
  end

  class Parser < Parslet::Parser
    rule(:float) do
      match['\d'].repeat(1) >> (str('.') >> match['\d'].repeat(1, 1)).maybe
    end

    rule(:description) do
      (str("\n").absent? >> any).repeat.as(:str) >> str("\n")
    end

    rule(:node) do
      str('- ') >> float.as(:float).as(:units) >> description.as(:description)
    end

    rule(:nodes) do
      node.as(:item).repeat
    end

    root(:nodes)
  end

  class ConsumptionItem
    attr_reader :units, :description
    def initialize(units:, description:)
      @units, @description = units, description
    end
  end

  class ConsumptionItems
    attr_reader :items
    def initialize(items)
      @items = items
    end

    def sum
      @items.sum(&:units)
    end
  end

  class Transformer < Parslet::Transform
    rule(str: simple(:slice)) { slice.to_s.strip }
    rule(float: simple(:amount_string)) do
      amount_string.to_f
    end

    rule(item: subtree(:data)) do
      ConsumptionItem.new(**data)
    end
  end
end

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::Consumption)
