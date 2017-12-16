require 'pomodoro/formats/today'
require 'pomodoro/config'

module Pomodoro::Formats::Today
  class Archive
    def initialize(glob)
      @glob = glob
    end

    def files
      @files ||= Dir.glob("#{self.data_root_path}/#{@glob}/**/*.today")
    end

    def data_root_path
      Pomodoro::Config.new.data_root_path
    end

    def lists
      @lists ||= self.files.map do |file|
        begin
          Pomodoro::Formats::Today.parse(File.new(file))
        rescue => error
          raise error.class.new("Error in #{file}: #{error.message}")
        end
      end
    end

    def months
      self.files.group_by do |path|
        path.split('/')[-3]
      end
    end

    def weeks
      self.files.group_by do |path|
        path.split('/')[-2..-3].join('/')
      end
    end
  end
end
