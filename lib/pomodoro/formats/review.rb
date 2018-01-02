require 'parslet'

module Pomodoro
  module Formats
    # {include:file:doc/formats/review.md}
    module Review
      # The entry point method for parsing this format.
      #
      # @param string [String] string in the review format
      # @return [TaskList, nil]
      #
      # @example
      #   require 'pomodoro/formats/review'
      #
      #   task_list = Pomodoro::Formats::Review.parse <<-EOF.gsub(/^\s*/, '')
      #     # Expenses
      #     ...
      #   EOF
      # @since 0.2
      def self.parse(string_or_io)
        string = string_or_io.respond_to?(:read) ? string_or_io.read : string_or_io
        tree = Parser.new.parse(string)
        nodes = Transformer.new.apply(tree)
        Sections.new(nodes.empty? ? Array.new : nodes)
      end

      module Plugins
      end
    end
  end
end

require 'pomodoro/formats/review/section'
require 'pomodoro/formats/review/sections'
require 'pomodoro/formats/review/parser/parser'
require 'pomodoro/formats/review/parser/transformer'

# For now let's load all the plugins.
require 'pomodoro/formats/review/plugins/accounts'
require 'pomodoro/formats/review/plugins/activities'
require 'pomodoro/formats/review/plugins/consumption'
require 'pomodoro/formats/review/plugins/expenses'
require 'pomodoro/formats/review/plugins/medical_data'
require 'pomodoro/formats/review/plugins/medications'
