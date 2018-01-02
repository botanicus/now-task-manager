# ```markdown
# # Accounts
#
# FIO USD: 751.25
# FIO CZK: 40000
# ```
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
