module Pomodoro
  class Task
    DEFAULT_DURATION = 10

    def self.parse(line)
      match = line.match(/^- (?:\[(\d+)\]\s+)?([^#]+)\s*/)
      text, duration = match[2], match[1] && match[1].to_i
      tags = line.scan(/#\S+/).map { |tag| tag[1..-1].to_sym }
      self.new(text.chomp(' '), duration, tags)
    end

    attr_reader :text, :duration, :tags
    def initialize(text, duration = nil, tags = [])
      @text, @duration, @tags = text, duration || DEFAULT_DURATION, tags
    end

    def to_s
      output = ['-']
      output << "[#{@duration}]" unless @duration == DEFAULT_DURATION
      output << @text
      output << @tags.map { |tag| "##{tag}"}.join(' ') unless @tags.empty?
      output.join(' ')
    end

    def command
      $1 if @text.match(/\$\s+(.+)$/)
    end
  end
end
