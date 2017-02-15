module Pomodoro
  class Task
    # Task.parse("- TopTal. #online #work 20")
    def self.parse(line)
      match = line.match(/^- ([^#]+).*?(\d+)?$/)
      text, duration = match[1], match[2] && match[2].to_i
      tags = line.scan(/#\S+/).map { |tag| tag[1..-1].to_sym }
      self.new(text, duration, tags)
    end

    def initialize(text, duration = 10, *tags)
      @text, @duration, @tags = text, duration, tags
    end

    def to_s
      ["- #{@text}", @tags.map { |tag| "##{tag}"}.join(' '), duration].join(' ')
    end
  end
end
