require 'pomodoro/exts/hour'

module Pomodoro
  class TimeFrame
    ALLOWED_OPTIONS ||= [:online, :writeable, :note, :tags]

    def initialize(name, tag, interval_from, interval_to, options = Hash.new)
      @name, @tag, @options = name, tag, options
      @interval = [Hour.parse(interval_from), Hour.parse(interval_to)]

      unless (unrecognised_options = options.keys - ALLOWED_OPTIONS).empty?
        raise ArgumentError.new("Unrecognised options: #{unrecognised_options.inspect}")
      end
    end

    def method_name
      if @name
        @name.downcase.tr(' ', '_').to_sym
      else
        :default
      end
    end
  end
end
