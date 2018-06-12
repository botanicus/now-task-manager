# frozen_string_literal: true

require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  # - A task. #cool
  #   Log about how is it going with the task.
  #
  #   One more paragraph.
  #
  #   ✔ Subtask 1.
  #   ✘ Subtask 2.
  #   - Subtask 3.
  #
  #   Postponed: I got bored of it.
  class Metadata
    attr_reader :lines, :subtasks, :metadata
    def initialize(lines: [], subtasks: [], metadata: {})
      @lines, @subtasks, @metadata = lines, subtasks, metadata
      @lines.is_a?(Array)    || raise ArgumentError, "Lines must be an array!"
      @subtasks.is_a?(Array) || raise ArgumentError, "Subtasks must be an array!"
      @metadata.is_a?(Hash)  || raise ArgumentError, "Metadata must be an array!"
    end

    def []=(key, value)
      raise ArgumentError.new("....") if @metadata['Postponed'] && key == 'Failed'
    end

    def to_s
      @lines.join("\n\n")
      @subtasks.join("\n")
      @metadata.reduce(Array.new) do |buffer, (key, value)|
        buffer << "#{key}: #{value}"
      end
    end
  end
end
