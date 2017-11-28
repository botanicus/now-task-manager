require 'pomodoro/exts/hour'

module Pomodoro
  class TimeFrame
    ALLOWED_OPTIONS ||= [:online, :writeable, :note, :tags]

    attr_reader :name, :tasks, :interval, :options
    def initialize(name, tag, interval_from, interval_to, options = Hash.new)
      @name, @tag, @options = name, tag, options
      @interval = [interval_from && Hour.parse(interval_from), interval_to && Hour.parse(interval_to)]
      @tasks = Array.new

      unless (unrecognised_options = options.keys - ALLOWED_OPTIONS).empty?
        raise ArgumentError.new("Unrecognised options: #{unrecognised_options.inspect}")
      end
    end

    def header
      if @interval[0] && @interval[1]
        "#{@name} (#{@interval[0]} – #{@interval[1]})"
      elsif @interval[0] && ! @interval[1]
        "#{@name} (from #{@interval[0]})"
      elsif ! @interval[0] && @interval[1]
        raise "I don't think this makes sense."
      else
        @name
      end
    end

    def to_s
      if @tasks.empty?
        self.header
      else
        ["#{self.header}:", self.tasks.map(&:to_s)].join("\n")
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
