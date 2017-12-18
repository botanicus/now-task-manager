require 'parslet'
# require 'parslet/convenience' # parse_with_debug

module Pomodoro
  module Formats
    # {include:file:doc/formats/today.md}
    module Today
      # TODO: spec me.
      class DataInconsistencyError < StandardError
      end

      # The entry point method for parsing this format.
      #
      # @param string [String] string in the today task list format
      # @return [TaskList, nil]
      #
      # @example
      #   require 'pomodoro/formats/today'
      #
      #   task_list = Pomodoro::Formats::Today.parse <<-EOF.gsub(/^\s*/, '')
      #     Morning routine (from 7:50)
      #     - Headspace. #meditation
      #
      #     Admin (9:20 – 10:00)
      #     - [9:20] Call with Mike.
      #   EOF
      # @since 1.0
      def self.parse(string_or_io)
        string = string_or_io.respond_to?(:read) ? string_or_io.read : string_or_io
        path   = string_or_io.path if string_or_io.respond_to?(:path)
        tree   = Parser.new.parse(string)
        nodes  = Transformer.new.apply(tree)
        Day.new(path: path, nodes: nodes)
      rescue => error
        raise error.class.new("Error in #{path}: #{error.message}")
      end
    end
  end
end

require 'pomodoro/formats/today/day'
require 'pomodoro/formats/today/task_list'
require 'pomodoro/formats/today/time_frame'
require 'pomodoro/formats/today/task'
require 'pomodoro/formats/today/parser/parser'
require 'pomodoro/formats/today/parser/transformer'
