require 'pomodoro/exts/hour'
require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  # TODO: Document the purpose.
  class TimeFrameInsufficientTimeInfoError < DataInconsistencyError
    def initialize(missing_values)
      super <<-EOF.gsub(/^ */, '')
       The following values were not present: #{missing_values.keys.join(' and ')}

       Full data: #{missing_values.inspect}

       Every time frame has to have a start_time and an end_time: if not explicitly,
       then the info has to be present on the previous/next time frame.
     EOF
    end
  end

  class TimeFrame
    # @since 0.2
    attr_reader :name, :start_time, :end_time, :items

    # @param name [String] name of the task group.
    # @param start_time [Hour] of when the time frame starts.
    # @param end_time [Hour] of when the time frame ends.
    # @param tasks [Array<Task>] tasks of the group.
    # @raise ArgumentError if name is not present, neither start_time or end_time
    #   is present or one of the times is not an Hour instance or if tasks is not
    #   an array of task-like objects.
    # @since 0.2
    #
    # @example
    #   require 'pomodoro/formats/today'
    #
    #   time_frame = Pomodoro::Formats::Today::TimeFrame.new(
    #     name: 'Morning routine', start_time: Hour.parse('7:50'), items: [
    #       Pomodoro::Formats::Today::Task.new(status: :done, body: 'Headspace.')
    #     ]
    #   )
    def initialize(name:, start_time: nil, end_time: nil, items: Array.new)
      @name, @start_time, @end_time, @items = name, start_time, end_time, items

      # This is not true, because it can be determined by the next/previous time frame.
      # https://github.com/botanicus/now-task-manager/issues/20
      # if @start_time.nil? && @end_time.nil?
      #   raise ArgumentError.new("At least one of start_time and end_time has to be provided.")
      # end

      unless [@start_time, @end_time].compact.all? { |time| time.is_a?(Hour) }
        raise ArgumentError.new("Start time and end time has to be an Hour instance.")
      end

      task_methods = [:status, :body, :start_time, :end_time, :metadata]
      unless items.is_a?(Array) && items.all? { |item| item.is_a?(Task) || item.is_a?(LogItem) }
        raise ArgumentError.new("Items is supposed to be an array of Task or LogItem instances.")
      end
    end

    def tasks
      self.items.select { |item| item.is_a?(Task) }
    end

    def log_items
      self.items.select { |item| item.is_a?(LogItem) }
    end

    # Return overall duration of the time frame.
    #
    # @param [Hour] prev_time_frame_end_time
    # @param [Hour] next_time_frame_end_time
    # @raise [ArgumentError]
    # @raise [TimeFrameInsufficientTimeInfoError]
    # @return [Hour]
    # @since 0.2
    # @example
    #   # TODO
    def duration(prev_time_frame_end_time = nil, next_time_frame_start_time = nil)
      start_time = @start_time || prev_time_frame_end_time
      end_time = @end_time || next_time_frame_start_time

      validate_time_info_consistency(start_time, end_time)

      end_time - start_time
    end

    def duration_ # TODO: Rename neco jako cistyho casu.
      self.tasks.reduce(0) do |sum, task|
        (task.ended? && task.actual_duration) ? task.actual_duration + sum : sum
      end
    end

    def actual_duration
      last_finished_task = self.tasks.reverse.find(&:end_time)
      last_finished_task.end_time - self.tasks.first.start_time
    end

    # Return true or false based on whether the time frame is active
    # in the provided current_time.
    #
    # @param [Hour] current_time
    # @param [Hour] prev_time_frame_end_time
    # @param [Hour] next_time_frame_end_time
    # @raise [ArgumentError]
    # @raise [TimeFrameInsufficientTimeInfoError]
    # @return [Boolean]
    # @since 0.2
    # @example
    #   # TODO
    def active?(current_time = Hour.now, prev_time_frame_end_time = nil, next_time_frame_start_time = nil)
      unless current_time.is_a?(Hour)
        raise ArgumentError.new("Current time has to be an Hour instance, was #{current_time.class}.")
      end

      start_time = @start_time || (prev_time_frame_end_time || Hour.parse('0:00'))
      end_time = @end_time || (next_time_frame_start_time || Hour.parse('23:59'))

      validate_time_info_consistency(start_time, end_time)

      start_time <= current_time && end_time > current_time
    end

    # Return a today task list formatted string.
    #
    # @since 0.2
    def to_s
      if self.items.empty?
        "#{self.header}\n"
      else
        "#{self.header}\n#{self.items.map(&:to_s).join}"
      end
    end

    # Name of method that will be available on a {TaskList task list} to access a time frame.
    #
    # @example
    #   Pomodoro::Formats::Today::TimeFrame.new(
    #     name: "Morning routine",
    #     start_time: Hour.parse('7:50')
    #   ).method_name
    #
    #   # => :morning_routine
    # @since 0.2
    def method_name
      @name.downcase.tr(' ', '_').to_sym
    end

    def create_task(body, duration = nil, tags = Array.new)
      @items << Task.new(status: :not_done, body: body, tags: tags)
    end

    # def clear
    #   @tasks.clear
    # end

    def remaining_duration
      @end_time && (@end_time - Hour.now)
    end

    def first_unstarted_task
      self.tasks.find do |task|
        task.unstarted?
      end
    end

    def active_task
      self.tasks.find do |task|
        task.in_progress?
      end
    end

    def header
      if @start_time && @end_time
        [@name, "(#{@start_time} – #{@end_time})"].compact.join(' ')
      elsif @start_time && ! @end_time
        [@name, "(from #{@start_time})"].compact.join(' ')
      elsif ! @start_time && @end_time
        [@name, "(until #{@end_time})"].compact.join(' ')
      end
    end

    protected
    def validate_time_info_consistency(start_time, end_time)
      values = {start_time: start_time, end_time: end_time}
      missing_values = values.select { |_, value| value.nil? }

      unless missing_values.empty?
        raise TimeFrameInsufficientTimeInfoError.new(missing_values)
      end

      if start_time && end_time && start_time > end_time
        raise ArgumentError.new("Start time cannot be bigger than end time.")
      end
    end
  end
end
