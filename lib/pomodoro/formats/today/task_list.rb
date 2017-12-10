require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class TaskList
    include Enumerable

    # @since 1.0
    attr_reader :time_frames

    def initialize(time_frames)
      @time_frames = time_frames

      time_frames.each do |time_frame|
        self.define_singleton_method(time_frame.method_name) do
          time_frame
        end
      end
    end

    def get_current_time_frame(current_time = Time.now)
      @time_frames.find do |time_frame|
        starting_time, closing_time = time_frame.interval
        starting_time < current_time && (closing_time.nil? || closing_time > current_time)
      end
    end

    def each(&block)
      @time_frames.each(&block)
    end


    def duration
      self.time_frames.sum { |time_frame| time_frame.duration }
    end

    # def has_unfinished_tasks?
    #   @time_frames.any?(&:has_unfinished_tasks?)
    # end

    def to_s
      self.time_frames.reduce(nil) do |buffer, time_frame|
        buffer ? "#{buffer}\n\n#{time_frame.to_s}" : "#{time_frame.to_s}"
      end
    end

    def save(path)
      data = self.to_s
      File.open(path, 'w') do |file|
        file.puts(data)
      end
    end
  end
end
