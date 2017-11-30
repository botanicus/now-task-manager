module Pomodoro
  class TaskList
    def self.parse(path)
      # Now ... some stuff is in the schedules definition, NOT in the parsed file.
      #   Is it ... since the schedule can be defined in-line (say I have a Skype call from 5 to 6).
      # The schedules can differ
      #
      # This does not make manager (totally) obsolete as its format is used
      # for the upcoming days and contexts (such as CZ).
      time_frames = File.readlines(path, encoding: 'utf-8').reduce(Array.new) do |time_frames, line|
        case line
        when /^- /
          time_frames.last.tasks << Task.parse(line.chomp)
          time_frames
        when /^(\s*|\s*#.*)$/
          time_frames
        else
          time_frames << TimeFrame.parse(line.chomp)
        end
      end

      self.new(time_frames)
    end

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
        starting_time < current_time && closing_time > current_time
      end
    end

    # def has_unfinished_tasks?
    #   @time_frame_list.any?(&:has_unfinished_tasks?)
    # end

    def to_s
      self.time_frame_list.reduce(nil) do |buffer, time_frame|
        buffer ? "#{buffer}\n\n#{time_frame.to_s}" : "#{time_frame.to_s}"
      end
    end
  end
end
