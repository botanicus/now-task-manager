# frozen_string_literal: true

require 'parslet'
require 'parslet/convenience' # parse_with_debug

module Pomodoro
  module Formats
    # {include:file:doc/formats/scheduled.md}
    module Scheduled
      # The entry point method for parsing this format.
      #
      # @param string [String] string in the scheduled task list format
      # @return [TaskList, nil]
      #
      # @example
      #   require 'pomodoro/formats/scheduled'
      #
      #   task_list = Pomodoro::Formats::Scheduled.parse <<-EOF.gsub(/^\s*/, '')
      #     Tomorrow
      #     - Buy milk. #errands
      #     - [9:20] Call with Mike.
      #
      #     Prague
      #     - Pick up my shoes. #errands
      #   EOF
      # @since 0.2
      def self.parse(string_or_io)
        string = string_or_io.respond_to?(:read) ? string_or_io.read : string_or_io
        tree = Parser.new.parse_with_debug(string)
        nodes = Transformer.new.apply(tree)
        TaskList.new(nodes.empty? ? Array.new : nodes)
      end
    end
  end
end

require 'pomodoro/formats/scheduled/parser/parser'
require 'pomodoro/formats/scheduled/parser/transformer'
require 'pomodoro/formats/scheduled/task'
require 'pomodoro/formats/scheduled/task_list'
require 'pomodoro/formats/scheduled/task_group'
