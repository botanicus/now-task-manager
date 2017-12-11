require 'pomodoro/exts/hour'
require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class TimeFrame
    include Enumerable

    # @since 1.0
    attr_reader :name, :start_time, :end_time, :tasks

    # @param name [String] name of the task group.
    # @param start_time [Hour] of when the time frame starts.
    # @param end_time [Hour] of when the time frame ends.
    # @param tasks [Array<Task>] tasks of the group.
    # @raise ArgumentError if name is not present, neither start_time or end_time
    #   is present or one of the times is not an Hour instance or if tasks is not
    #   an array of task-like objects.
    # @since 1.0
    #
    # @example
    #   require 'pomodoro/formats/today'
    #
    #   time_frame = Pomodoro::Formats::Today::TimeFrame.new(
    #     name: 'Morning routine', start_time: Hour.parse('7:50'), tasks: [
    #       Pomodoro::Formats::Today::Task.new(status: :done, body: 'Headspace.')
    #     ]
    #   )
    def initialize(name:, start_time: nil, end_time: nil, tasks: Array.new)
      @name, @start_time, @end_time, @tasks = name, start_time, end_time, tasks

      if @start_time.nil? && @end_time.nil?
        raise ArgumentError.new("At least one of start_time and end_time has to be provided.")
      end

      unless [@start_time, @end_time].compact.all? { |time| time.is_a?(Hour) }
        raise ArgumentError.new("Start time and end time has to be an Hour instance.")
      end

      task_methods = [:status, :body, :start_time, :end_time, :metadata]
      unless tasks.is_a?(Array) && tasks.all? { |item| task_methods.all? { |method| item.respond_to?(method) }}
        raise ArgumentError.new("Tasks is supposed to be an array of Task instances.")
      end
    end

    # Return overall duration of the time frame.
    #
    # @return [Hour]
    # @since 1.0
    # TODO: update docs and specs.
    def duration(prev_time_frame_end_time = nil, next_time_frame_start_time = nil)
      (@end_time || next_time_frame_start_time) - (@start_time || prev_time_frame_end_time)
    end

    # Return true or false based on whether the time frame is active
    # in the provided current_time.
    #
    # @param [Time] current_time
    # @return [Boolean]
    # @since 1.0
    def active?(prev_time_frame_end_time = nil, next_time_frame_start_time = nil, current_time = Time.now)
      start_time = @start_time || prev_time_frame_end_time
      end_time = @end_time || next_time_frame_start_time

      # This is very useful, do it elsewhere for validations as well.
      values = {start_time: start_time, end_time: end_time}
      missing_values = values.select { |_, value| value.nil? }

      unless missing_values.empty?
        raise DataInconsistencyError.new <<-EOF.gsub(/^\s*/, '')
          The following values were not present: #{missing_values.inspect}

          Every time frame has to have a start_time and end_time: if not explicitly,
          then by the previous or next time frame time limit.
        EOF
      end

      @start_time.to_time < current_time && @end_time.to_time > current_time
    end

    # Return a today task list formatted string.
    #
    # @since 1.0
    def to_s
      if @tasks.empty?
        "#{self.format_header}\n"
      else
        ["#{self.format_header}", self.tasks.map(&:to_s)].join("\n")
      end
    end

    # Iterate over the tasks.
    #
    # @yieldparam [Task] task
    # @since 1.0
    def each(&block)
      @tasks.each(&block)
    end

    # Name of method that will be available on a task list to access a time frame.
    #
    # @example
    #   Pomodoro::Formats::Today::TimeFrame.new(
    #     name: "Morning routine",
    #     start_time: Hour.parse('7:50')
    #   ).method_name
    #
    #   # => :morning_routine
    # @since 1.0
    def method_name
      @name.downcase.tr(' ', '_').to_sym
    end

    protected
    def format_header
      if @start_time && @end_time
        [@name, "(#{@start_time} – #{@end_time})"].compact.join(' ')
      elsif @start_time && ! @end_time
        [@name, "(from #{@start_time})"].compact.join(' ')
      elsif ! @start_time && @end_time
        [@name, "(until #{@end_time})"].compact.join(' ')
      end
    end
  end
end
