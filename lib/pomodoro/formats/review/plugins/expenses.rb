# frozen_string_literal: true

require 'forwardable'

# @example
# ```markdown
# # Expenses
#
# PLN 14 + 2 Lunch at Parniczek. #lunch
# [FIO VISA] USD 10.78 Domain extension.
#   It was supposed to be 8.99, but I got charged 10.78.
# ```
# @example
# ```ruby
#   [#<Pomodoro::Formats::Review::Plugins::Expenses::Expense:0x00007fb229222f08
#     @amount=14.0,
#     @currency=:PLN,
#     @description="Lunch at Parniczek. #lunch",
#     @notes=[],
#     @payment_method="cash",
#     @tip=2.0>,
#    #<Pomodoro::Formats::Review::Plugins::Expenses::Expense:0x00007fb22921bfa0
#     @amount=10.78,
#     @currency=:USD,
#     @description="Domain extension.",
#     @notes=[],
#     @payment_method="FIO VISA",
#     @tip=0>]>
# ```

# TODO:
# Add totals:
# PLN 10 lunch
# USD 9 domain
# Total USD: 9
# Total PLN: 10
# Overall total: 14 USD
#
# Don't parse it, it'd be updated from the data.
# ! No, do parse it for the total in our base currency,
# so we don't have to dig online historic data or cash it elsewhere.
module Pomodoro::Formats::Review::Plugins::Expenses
  HEADER ||= 'Expense'

  def self.parse(string)
    tree = Parser.new.parse(string)
    nodes = Transformer.new.apply(tree)
    Expenses.new(nodes.empty? ? Array.new : nodes)
  end

  class Parser < Parslet::Parser
    rule(:payment_method) do
      str('[') >> (str(']').absent? >> any).repeat.as(:str) >> str(']')
    end

    rule(:currency) { match['A-Z'].repeat(3).as(:str) }

    rule(:amount) do
      (match['\d'].repeat(1) >> (str('.') >> match['\d'].repeat(2, 2)).maybe).as(:float)
    end

    rule(:amount_and_tip) do
      amount.as(:amount) >> (str(' + ') >> amount).maybe.as(:tip)
    end

    rule(:description) do
      (str("\n").absent? >> any).repeat(1).as(:str) >> str("\n")
    end

    rule(:note_line) do
      str('  ') >> (str("\n").absent? >> any).repeat(1).as(:str) >> str("\n")
    end

    rule(:expense) do
      (payment_method.as(:payment_method) >> str(' ')).maybe >>
        currency.as(:currency) >> str(' ').repeat >>
        amount_and_tip >>
        description.as(:description) >>
        note_line.repeat.as(:notes)
    end

    rule(:expenses) { expense.as(:expense).repeat }

    root(:expenses)
  end

  class Expense
    attr_reader :amount, :tip, :currency, :description, :payment_method, :notes
    def initialize(amount:, tip: 0, currency:, description:, payment_method: 'cash', notes: Array.new)
      @amount, @tip, @currency = amount, tip, currency
      @description, @payment_method, @notes = description, payment_method, notes
    end

    def total
      self.amount + self.tip
    end
  end

  class Expenses
    extend Forwardable

    def_delegators :expenses, :length, :[]

    attr_reader :expenses
    def initialize(expenses)
      @expenses = expenses
    end

    def totals
      @expenses.group_by(&:currency).reduce(Hash.new) do |buffer, (currency, expenses)|
        buffer.merge(currency => expenses.sum(&:total))
      end
    end
  end

  class Transformer < Parslet::Transform
    rule(str: simple(:slice)) { slice.to_s.strip }

    rule(float: simple(:amount_string)) do
      amount_string.to_f
    end

    rule(tip: simple(:tip)) { tip || 0 } # [1]

    rule(currency: simple(:currency)) { currency.to_sym } # [1]
    # [1] It doesn't match all the keys in the hash, therefore it never matches.

    rule(expense: subtree(:data)) do
      data[:currency] = data[:currency].to_sym # [1]
      data.delete(:tip) if data[:tip].nil? # [1]
      Expense.new(**data)
    end

    rule(expenses: subtree(:expenses)) do
      Expenses.new(expenses)
    end
  end
end

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::Expenses)
