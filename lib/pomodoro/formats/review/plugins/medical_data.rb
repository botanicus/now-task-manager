# frozen_string_literal: true

# ```markdown
# # Medical data
#
# Weight: 69.9 kg
# Sun exposure: 2 hours, result: OK.
#
# Today I felt ...
# ```
module Pomodoro::Formats::Review::Plugins::MedicalData
  HEADER ||= 'Medical data'

  def self.parse(string)
    tree = Parser.new.parse(string)
    nodes = Transformer.new.apply(tree)
    nodes.empty? ? Array.new : nodes
  end

  class Parser < Parslet::Parser
    rule(:type) {
      (str(':').absent? >> any).repeat.as(:sym) >> str(':')
    }

    rule(:description) {
      (str("\n").absent? >> any).repeat.as(:str) >> str("\n")
    }

    rule(:note_line) {
      str('  ') >> (str("\n").absent? >> any).repeat(1).as(:str) >> str("\n")
    }

    rule(:node) {
      type.as(:type) >> description.as(:description) >> note_line.repeat.as(:notes)
    }

    rule(:nodes) {
      node.as(:node).repeat
    }

    root(:nodes)
  end

  class MedicalEvent
    TYPES ||= [
      :weight, :incident, :blood_pressure, :blood_glucose
    ]

    attr_reader :type, :description, :notes
    def initialize(type:, description:, notes: Array.new)
      @type, @description, @notes = type, description, notes
      unless TYPES.include?(type)
        raise ArgumentError.new("Unknown type: #{type}")
      end
    end
  end

  class Transformer < Parslet::Transform
    rule(str: simple(:slice)) { slice.to_s.strip }
    rule(sym: simple(:slice)) { slice.to_s.strip.downcase.tr(' ', '_').to_sym }
    rule(node: subtree(:data)) {
      MedicalEvent.new(**data)
    }
  end
end

Pomodoro::Formats::Review::Section.register(Pomodoro::Formats::Review::Plugins::MedicalData)
