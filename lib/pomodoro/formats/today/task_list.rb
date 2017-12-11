require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class TaskList
    include Enumerable

    # @since 1.0
    attr_reader :time_frames

    # Create a list of time frames and define a shortcut method on the task list
    # for accessing them by {TimeFrame#method_name their #method_name}.
    #
    # @param [Array<TimeFrame>] time_frames
    # @see TimeFrame#method_name
    # @since 1.0
    #
    # @example
    #   require 'pomodoro/formats/today'
    #
    #   task_list = Pomodoro::Formats::Today::TaskList.new(
    #     Pomodoro::Formats::Today::TimeFrame.new(
    #       name: 'Morning routine', start_time: Hour.parse('7:50'), tasks: [
    #         Pomodoro::Formats::Today::Task.new(status: :done, body: 'Headspace.')
    #       ]
    #     )
    #   )
    #
    #   # Now you can access the time frame by their method name.
    #   task_list.morning_routine
    def initialize(*time_frames)
      @time_frames = time_frames

      time_frame_methods = [:method_name]
      unless time_frames.is_a?(Array) && time_frames.all? { |item| time_frame_methods.all? { |method| item.respond_to?(method) }}
        raise ArgumentError.new("Time frames is supposed to be an array of TimeFrame-like instances.")
      end

      time_frames.each do |time_frame|
        self.define_singleton_method(time_frame.method_name) do
          time_frame
        end
      end
    end

    # Iterate over the time frames.
    #
    # @yieldparam [TimeFrame] time_frame
    # @since 1.0
    def each(&block)
      @time_frames.each(&block)
    end

    # Iterate over the tasks of each time frame.
    #
    # @yieldparam [Task] task
    # @since 1.0
    def each_task(&block)
      @time_frames.map(&:tasks).flatten.each(&block)
    end

    # Return overall duration.
    #
    # @return [Hour]
    # @since 1.0
    def duration
      enumerator = self.time_frames.each.with_index
      enumerator.reduce(0) do |sum, (time_frame, index)|
        # TODO: is there some better solution using enumerator.next? I can't find
        # any enumerator.prev.
        if index == 0
          prev_time_frame_end_time = Hour.parse('0:00')
        else
          prev_time_frame_end_time = @time_frames[index - 1].end_time
        end

        if index == (@time_frames.length - 1)
          next_time_frame_start_time = Hour.parse('23:59')
        else
          next_time_frame_start_time = @time_frames[index + 1].start_time
        end

        time_frame.duration(prev_time_frame_end_time, next_time_frame_start_time) + sum
      end
    end

    # Return a today task list formatted string.
    #
    # @since 1.0
    def to_s
      self.time_frames.reduce(nil) do |buffer, time_frame|
        buffer ? "#{buffer}\n\n#{time_frame.to_s}" : "#{time_frame.to_s}"
      end
    end

    # @!group Finders

    # Return the currently active task, regardless of the time frame we are in.
    #
    # @since 1.0
    def active_task
      self.each_task.find(&:in_progress?)
    end

    # Return the currently active time frame.
    #
    # @since 1.0
    def current_time_frame(current_time = Time.now)
      @time_frames.find do |time_frame|
        time_frame.active?(current_time)
      end
    end

    # def has_unfinished_tasks?
    #   @time_frames.any?(&:has_unfinished_tasks?)
    # end

    # @!endgroup
  end
end
