require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class TaskList
    attr_reader :time_frame_list
    def initialize(time_frame_list)
      @time_frame_list = time_frame_list

      time_frame_list.each do |time_frame|
        self.define_singleton_method(time_frame.method_name) do
          time_frame
        end
      end
    end

    def get_current_time_frame(current_time = Time.now)
      @time_frame_list.find do |time_frame|
        starting_time, closing_time = time_frame.interval
        starting_time < current_time && (closing_time.nil? || closing_time > current_time)
      end
    end

    include Enumerable
    def each(&block)
      @time_frame_list.each(&block)
    end


    def duration
      self.time_frame_list.sum { |time_frame| time_frame.duration }
    end

    # def has_unfinished_tasks?
    #   @time_frame_list.any?(&:has_unfinished_tasks?)
    # end

    def to_s
      self.time_frame_list.reduce(nil) do |buffer, time_frame|
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
