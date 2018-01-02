# ```markdown
# # Accounts
#
# FIO USD: 751.25
# FIO CZK: 40000
# ```
# TODO:
# Add totals:
# FIO USD: 751.25
# FIO CZK: 40000
# Total USD: 751.25
# Total CZK: 40000
# Overall total: xxx USD
#
# Don't parse it, it'd be updated from the data.
module Pomodoro::Formats::Review::Plugins::Accounts
  HEADER ||= 'Account balances'

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

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::Accounts)
