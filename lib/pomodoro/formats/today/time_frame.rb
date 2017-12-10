require 'pomodoro/exts/hour'
require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class TimeFrame
    include Enumerable

    # @since 1.0
    attr_reader :name, :start_time, :end_time, :tasks

    # @param name [String] name of the task group.
    # @param tasks [Array<String>] tasks of the group.
    # @since 1.0
    #
    # @example
    #   require 'pomodoro/formats/today'
    #
    #   time_frame = Pomodoro::Formats::Today::TimeFrame.new(
    #     name: 'Morning routine', tasks: [
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
        raise ArgumentError.new("Data is supposed to be an array of Task instances.")
      end
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
      @tasks.each do |task|
        block.call(task)
      end
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
