# ```markdown
# # Medical data
#
# Weight: 69.9 kg
#
# Today I felt ...
# ```
module Pomodoro::Formats::Review::Plugins::MedicalData
  HEADER ||= 'Medical data'

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

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::MedicalData)
