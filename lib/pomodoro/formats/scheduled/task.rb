# frozen_string_literal: true

require 'pomodoro/formats/scheduled'

module Pomodoro::Formats::Scheduled
  class Task
    attr_reader :body, :time_frame, :start_time, :tags

    # Create a new scheduled task.
    #
    # @param body [String] the task description.
    # @param start_time [Hour] when the task starts.
    # @param time_frame [String] name, initials or an abbreviation of a time frame
    #   to which the task will be scheduled.
    # @param tags [Array<Symbol>] list of tags.
    def initialize(body:, time_frame: nil, start_time: nil, tags: Array.new)
      @body, @time_frame, @start_time, @tags = body, time_frame, start_time, tags

      raise ArgumentError, "Body cannot be empty." if body.empty?

      if start_time && !start_time.is_a?(Hour)
        raise ArgumentError, "Hour instance was expected, got #{start_time.class}"
      end

      if !tags.empty? && tags.any? { |tag| !tag.is_a?(Symbol) }
        raise ArgumentError, "Tags are supposed to be an array of symbols."
      end
    end

    # Format task in the {Pomodoro::Formats::Scheduled scheduled task list format}.
    # @since 0.2
    def to_s
      [
        '-',
        ("[#{@time_frame}]" if @time_frame),
        ("[#{@start_time}]" if @start_time),
        @body.to_s, *@tags.map { |tag| "##{tag}" }
      ].compact.join(' ')
    end
  end
end
