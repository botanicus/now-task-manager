require 'pomodoro/exts/hour'
require 'pomodoro/formats/today'
require 'pomodoro/formats/today/task/statuses'
require 'pomodoro/formats/today/task/dynamic_additions'
require 'pomodoro/formats/today/task/metadata'

module Pomodoro::Formats::Today
  class Task
    STATUS_MAPPING ||= {
      not_done: ['-'],
      done: ['✓', '✔', '☑'],
      failed:   ['✕', '☓', '✖', '✗', '✘', '☒'],
      # wip:      ['☐', '⛶', '⚬']
    }

    STATUS_LIST ||= STATUS_MAPPING.keys

    include TaskStatuses
    include DynamicAdditions

    attr_reader :status, :body, :start_time, :end_time, :fixed_start_time, :duration, :tags, :lines
    def initialize(status:, body:, start_time: nil, end_time: nil, fixed_start_time: nil, duration: nil, tags: [], lines: [])
      @status, @body, @tags, @duration = status, body, tags, duration
      @start_time, @end_time, @fixed_start_time = start_time, end_time, fixed_start_time
      validate_data_integrity
    end

    def remaining_duration(current_time_frame)
      @start_time || raise("The task #{self.inspect} hasn't been started yet.")

      closing_time = @start_time + duration
      interval_end_time = current_time_frame.interval[1]
    end

    def to_s
      Formatter.format(self)
    end

    private
    def format_duration
      if @start_time && @end_time
        [@start_time, @end_time].join('-')
      elsif @start_time
        "started at #{@start_time}"
      elsif @end_time
        raise 'nonsense'
      else # nil
      end
    end

    def validate_nil_or_instance_of(expected_class, instance, var_name)
      instance && (instance.is_a?(expected_class) ||
        raise(ArgumentError.new("#{var_name} has to be an instance of #{expected_class}.")))
    end

    def validate_data_integrity
      validate_nil_or_instance_of(Hour, @start_time,       :start_time)
      validate_nil_or_instance_of(Hour, @end_time,         :end_time)
      validate_nil_or_instance_of(Hour, @fixed_start_time, :fixed_start_time)

      if @start_time.nil? && @end_time
        raise ArgumentError.new("Setting end_time without start_time is invalid.")
      end

      if @start_time && @end_time && @start_time >= @end_time
        raise ArgumentError.new("start_time has to be smaller than end_time.")
      end

      if @duration && ! (@duration.respond_to?(:integer?) && @duration.integer?)
        raise ArgumentError.new("Duration has to be an integer.")
      end

      if @duration && ! (5..90).include?(@duration)
        raise ArgumentError.new("Duration has between 5 and 90 minutes.")
      end

      unless STATUS_LIST.include?(@status)
        raise ArgumentError.new("Status has to be one of #{STATUS_SYMBOLS.keys.inspect}.")
      end

      # Unstarted or in progress.
      if @status == :not_done && @end_time
        raise ArgumentError.new("A task with status :not_done cannot have an end_time!")
      end

      if [:done, :failed].include?(@status) && ! (
        (@start_time && @end_time) || (! @start_time && ! @end_time))
        raise ArgumentError.new("Task has ended. It can either have start_time and end_time or neither, not only one of them.")
      end
    end
  end
end
