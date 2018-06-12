# frozen_string_literal: true

require 'refined-refinements/hour'
require 'pomodoro/formats/today'
require 'pomodoro/formats/today/task/statuses'
require 'pomodoro/formats/today/task/dynamic_additions'
require 'pomodoro/formats/today/task/metadata'
require 'pomodoro/formats/today/task/formatter'

module Pomodoro::Formats::Today
  class Task
    # STATUS_SYMBOLS ||= {
    #   # Unfinished statuses.
    #   # Unstarted can be either tasks to be started,
    #   # or tasks skipped when time frame changed.
    #   unstarted: '-', in_progress: '-',
    #
    #   # maybe status :finished and :unfinished, but :unfinished would require Postponed/Deleted etc. (check dynamically)
    #   # Finished, as in done for the day.
    #   completed: '✔', progress_made: '✔', postponed: '✘', deleted: '✘'
    # }
    STATUS_MAPPING ||= {
      not_done: ['-'],
      done: ['✔', '✓', '☑'],
      failed:   ['✘', '✗', '✕', '☓', '✖', '☒'],
      # wip:      ['☐', '⛶', '⚬']
    }.freeze

    STATUS_LIST ||= STATUS_MAPPING.keys

    include TaskStatuses
    include DynamicAdditions

    attr_reader :status, :body, :start_time, :end_time, :fixed_start_time, :tags, :lines, :metadata
    attr_accessor :duration, :fixed_start_time
    def initialize(status:, body:, start_time: nil, end_time: nil, fixed_start_time: nil, duration: nil, tags: [], lines: [])
      @status, @body, @tags, @duration, @lines = status, body, tags, duration, lines
      @start_time, @end_time, @fixed_start_time = start_time, end_time, fixed_start_time
      validate_data_integrity
    end

    def metadata
      @metadata ||= @lines.each_with_object(Hash.new) do |line, hash|
        if match = line.match(/^(.+): +(.+)$/)
          hash[match[1]] = match[2]
        end
      end
    end

    def remaining_duration(current_time_frame, now = Hour.now)
      @start_time || raise("The task #{self.inspect} hasn't been started yet.")

      closing_time = @start_time + duration
      time_frame_end_time = current_time_frame.end_time
      [closing_time, time_frame_end_time].compact.min - now
    end

    # This works even when the task is only ticked off without having the times.
    def actual_duration
      @end_time - @start_time if @start_time && @end_time
    end

    def to_s
      Formatter.format(self)
    end

    private
    def validate_nil_or_instance_of(expected_class, instance, var_name)
      instance && (instance.is_a?(expected_class) ||
        raise ArgumentError, "#{var_name} has to be an instance of #{expected_class}.")
    end

    def validate_data_integrity
      validate_nil_or_instance_of(Hour, @start_time,       :start_time)
      validate_nil_or_instance_of(Hour, @end_time,         :end_time)
      validate_nil_or_instance_of(Hour, @fixed_start_time, :fixed_start_time)

      if @start_time.nil? && @end_time
        raise ArgumentError, "Setting end_time without start_time is invalid."
      end

      if @start_time && @end_time && @start_time >= @end_time
        raise ArgumentError, "start_time has to be smaller than end_time."
      end

      if @duration && !@duration.is_a?(Hour)
        raise ArgumentError, "Duration has to be an Hour instance."
      end

      # if @duration && @duration <= Hour.new(0, 5) || @duration >= Hour.new(1, 30)
      #   raise ArgumentError.new("Duration has between 5 and 90 minutes.")
      # end

      unless STATUS_LIST.include?(@status)
        raise ArgumentError, "Status has to be one of #{STATUS_MAPPING.keys.inspect}."
      end

      # Unstarted or in progress.
      if @status == :not_done && @end_time
        raise ArgumentError, "A task with status :not_done cannot have an end_time!"
      end

      if [:done, :failed].include?(@status) && !(
        (@start_time && @end_time) || (!@start_time && !@end_time))
        raise ArgumentError, "Task has ended. It can either have start_time and end_time or neither, not only one of them."
      end
    end
  end
end
