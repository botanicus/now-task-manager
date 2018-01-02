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

  class Parser < Parslet::Parser
  end

  class Expense
    def initialize(amount, currency, description)
    end
  end

  class Transformer < Parslet::Transformer
  end
end
