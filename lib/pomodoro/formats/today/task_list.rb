require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class TaskList
    include Enumerable

    # @since 0.2
    attr_reader :time_frames

    # Create a list of time frames and define a shortcut method on the task list
    # for accessing them by {TimeFrame#method_name their #method_name}.
    #
    # @param [Array<TimeFrame>] time_frames
    # @see TimeFrame#method_name
    # @since 0.2
    #
    # @example
    #   require 'pomodoro/formats/today'
    #
    #   task_list = Pomodoro::Formats::Today::TaskList.new(
    #     Pomodoro::Formats::Today::TimeFrame.new(
    #       name: 'Morning routine', start_time: Hour.parse('7:50'), items: [
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
        raise ArgumentError.new("Time frames is supposed to be an array of TimeFrame-like instances, was #{@time_frames.inspect}.")
      end

      time_frames.each do |time_frame|
        self.define_singleton_method(time_frame.method_name) do
          time_frame
        end
      end
    end

    def <<(time_frame)
      self.define_singleton_method(time_frame.method_name) do
        time_frame
      end

      @time_frames << time_frame
    end

    # Iterate over the time frames.
    #
    # @yieldparam [TimeFrame] time_frame
    # @since 0.2
    def each(&block)
      @time_frames.each(&block)
    end

    # Iterate over the tasks of each time frame.
    #
    # @yieldparam [Task] task
    # @since 0.2
    def each_task(&block)
      @time_frames.map(&:tasks).flatten.each(&block)
    end

    def each_task_with_time_frame(&block)
      if block
        @time_frames.each do |time_frame|
          time_frame.tasks.each do |task|
            block.call(time_frame, task)
          end
        end
      else
        self.enum_for(:each_task_with_time_frame)
      end
    end

    # Return overall duration.
    #
    # @return [Hour]
    # @since 0.2
    def duration
      self.with_prev_and_next.reduce(0) do |sum, (prev_time_frame, time_frame, next_time_frame)|
        prev_time_frame_end_time   = prev_time_frame ? prev_time_frame.end_time   : Hour.parse('0:00')
        next_time_frame_start_time = next_time_frame ? next_time_frame.start_time : Hour.parse('23:59')
        time_frame.duration(prev_time_frame_end_time, next_time_frame_start_time) + sum
      end
    end

    # @example
    #   task_list.with_prev_and_next.each do |prev_time_frame, time_frame, next_time_frame|
    #   end
    def with_prev_and_next(&block)
      # return enum_for(:with_prev_and_next) if block.nil?

      Enumerator.new do |yielder|
        if @time_frames.length == 1
          yielder << [nil, @time_frames[0], nil]
        elsif @time_frames.length > 1
          yielder << [nil, @time_frames[0], @time_frames[1]]
          @time_frames[1..-2].each.with_index do |time_frame, index|
            yielder << [@time_frames[index], time_frame, @time_frames[index + 2]]
          end
          yielder << [@time_frames[-2], @time_frames[-1], nil]
        end
      end
    end

    # @example
    #   task_list.with_prev_and_next_times.each do |time_frame, prev_time_frame_end_time, next_time_frame_start_time|
    #   end
    def with_prev_and_next_times
      # TODO
    end

    # Return a today task list formatted string.
    #
    # @since 0.2
    def to_s
      self.time_frames.reduce(nil) do |buffer, time_frame|
        buffer ? "#{buffer}\n#{time_frame.to_s}" : "#{time_frame.to_s}"
      end
    end

    # @!group Finders

    # Return the currently active task, regardless of the time frame we are in.
    #
    # @return [Task, nil]
    # @since 0.2
    def active_task
      self.each_task.find(&:in_progress?)
    end

    # Return the currently active time frame.
    #
    # @return [TimeFrame, nil]
    # @since 0.2
    def current_time_frame(current_time = Hour.now)
      result = self.with_prev_and_next.find do |prev_time_frame, time_frame, next_time_frame|
        prev_time_frame_end_time = prev_time_frame && prev_time_frame.end_time
        next_time_frame_start_time = next_time_frame && next_time_frame.start_time
        time_frame.active?(current_time, prev_time_frame_end_time, next_time_frame_start_time)
      end

      result && result[1]
    end

    # def has_unfinished_tasks?
    #   @time_frames.any?(&:has_unfinished_tasks?)
    # end

    # @!endgroup
  end
end
