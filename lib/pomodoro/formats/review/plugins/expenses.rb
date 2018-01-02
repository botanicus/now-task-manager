# ```markdown
# # Expenses
#
# PLN 14 Lunch at Parniczek.
# USD 8.99 Domain extension.
#
# OR
#
# Lunch 10 PLN
#   Description.
# ```
module Pomodoro::Formats::Review::Plugins::Expenses
  HEADER ||= 'Expense'

  def self.parse(string)
    tree = Parser.new.parse(string)
    nodes = Transformer.new.apply(tree)
    Expenses.new(nodes.empty? ? Array.new : nodes)
  end

  class Parser < Parslet::Parser
    rule(:currency) { match['A-Z'].repeat(3).as(:str) }

    rule(:amount) {
      (match['\d'].repeat(1) >> (str('.') >> match['\d'].repeat(2, 2)).maybe).as(:float)
    }

    rule(:description) {
      (str("\n").absent? >> any).repeat(1).as(:str) >> str("\n")
    }

    rule(:expense) {
      currency.as(:currency) >> str(' ').repeat >> amount.as(:amount) >> description.as(:description)
    }

    rule(:expenses) { expense.as(:expense).repeat }

    root(:expenses)
  end

  class Expense
    attr_reader :amount, :currency, :description, :note
    def initialize(amount:, currency:, description:, note: nil)
      @amount, @currency, @description, @note = amount, currency, description, note
    end
  end

  class Expenses
    attr_reader :expenses
    def initialize(expenses)
      @expenses = expenses
    end

    def totals
      @expenses.group_by
    end

    require 'forwardable'
    extend Forwardable
    def_delegators :expenses, :length, :[]
  end

  class Transformer < Parslet::Transform
    rule(str: simple(:slice)) { slice.to_s.strip }

    rule(float: simple(:amount_string)) do
      amount_string.to_f
    end

    rule(currency: simple(:currency)) { currency.to_sym }

    rule(expense: subtree(:data)) do
      Expense.new(**data)
    end

    rule(expenses: subtree(:expenses)) do
      Expenses.new(expenses)
    end
  end
end

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::Expenses)
