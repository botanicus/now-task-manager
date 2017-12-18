require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class Archive
    attr_reader :start_date, :end_date
    def initialize(start_date, end_date)
      @start_date, @end_date = start_date, end_date
      # TODO: Validate if start_date is smaller than end_date.
    end

    def days
      (@start_date..@end_date).map { |date| Day.for(date) }
    end

    def months
      map_to_days((@start_date..@end_date).group_by(&:month))
    end

    def weeks
      map_to_days((@start_date..@end_date).group_by(&:cweek))
    end

    private
    def map_to_days(hash)
      hash.reduce(Hash.new) do |buffer, (num, dates)|
        buffer.merge(num => dates.map { |date| Day.for(date) })
      end
    end
  end
end
