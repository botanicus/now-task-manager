require 'pomodoro/formats/today'

# TODO: instantiate with Expense, WeightRecord or whatever based on the keys.
module Pomodoro::Formats::Today
  class LogItem
    attr_reader :data
    def initialize(data)
      unless data.is_a?(Hash)
        raise ArgumentError.new("Hash expected, got #{data.class}")
      end

      @data = data
    end

    def [](key)
      @data[key.to_s]
    end

    def to_s
      blob = self.data.map { |key, value| "#{key}: #{value}" }.join(', ')

      "~ #{blob.sub(/^./) { $&.upcase }}.\n"
    end
  end
end
