require 'ostruct'
require 'pomodoro/formats/today'
require 'pomodoro/config'

module Pomodoro::Formats::Today
  class Archive
    def initialize(start_date, end_date)
      @start_date, @end_date = start_date, end_date
      # TODO: Validate if start_date is smaller than end_date.
    end

    def days
      (@start_date..@end_date).map do |date|
        OpenStruct.new(date: date, task_list: task_list_for(date))
      end
    end

    def months
      xxx((@start_date..@end_date).group_by(&:month))
    end

    def weeks
      xxx((@start_date..@end_date).group_by(&:cweek))
    end

    private
    def xxx(hash)
      hash.reduce(Hash.new) do |buffer, (num, date)|
        buffer[num] ||= Array.new
        buffer[num] << OpenStruct.new(date: date, task_list: task_list_for(date))
        buffer
      end
    end

    def task_list_for(date)
      path = Pomodoro.config.today_path(date)
      begin
        Pomodoro::Formats::Today.parse(File.new(path)) if File.exist?(path)
      rescue => error
        raise error.class.new("Error in #{path}: #{error.message}")
      end
    end
  end
end
