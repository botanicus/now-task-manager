module Pomodoro
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

    def to_s
      self.time_frame_list.reduce(nil) do |buffer, time_frame|
        buffer ? "#{buffer}\n\n#{time_frame.to_s}" : "#{time_frame.to_s}"
      end
    end
  end
end
