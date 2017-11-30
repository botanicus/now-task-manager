require 'pomodoro/exts/hour'

module Pomodoro
  class Task
    DEFAULT_DURATION = 10

    def self.parse(line)
      match = line.match(/^- (?:\[(\d+|\d+:\d+-(?:\d+:\d+|now))\])([^#]+)$/)
      return unless match

      if match[1].match(/^\d+$/)
        duration = match[1].to_i
        interval = Array.new
      else
        duration = nil
        interval = self.parse_interval(match[1])
      end

      tags = line.scan(/#\S+/).map { |tag| tag[1..-1].to_sym }
      self.new(match[2].strip, duration, interval, tags)
    end

    def self.parse_interval(blob)
      start_time_blob, finish_time_blob = blob.split('-')
      interval = Array.new

      if match = start_time_blob.match(/(\d+):(\d+)/)
        interval[0] = Hour.new(match[1].to_i, match[2].to_i)
      end

      if match = finish_time_blob.match(/(\d+):(\d+)/)
        interval[1] = Hour.new(match[1].to_i, match[2].to_i)
      elsif finish_time_blob == 'now'
        # void
      end

      interval
    end

    def self.format_interval(interval)
      start_time, finish_time = interval
      if start_time && finish_time
        [start_time, finish_time].join('-')
      elsif start_time
        [start_time, 'now'].join('-')
      elsif finish_time
        raise 'nonsense'
      else # nil
      end
    end

    attr_reader :text, :duration, :tags
    def initialize(text, duration = nil, interval = Array.new, tags = [])
      @text, @duration, @tags, @interval = text, duration || DEFAULT_DURATION, tags, interval
    end

    def to_s
      output = ['-']
      if self.finished? && ! @interval.empty?
        output << "[#{self.class.format_interval(@interval)}]"
      else
        output << "[#{@duration}]" unless @duration == DEFAULT_DURATION
      end
      output << @text
      output << @tags.map { |tag| "##{tag}"}.join(' ') unless @tags.empty?
      output.join(' ')
    end

    def command
      $1 if @text.match(/\$\s+(.+)$/)
    end

    def start
      @interval[0] = Hour.now
    end

    def finish
      @interval[1] = Hour.now
    end

    def status
      return :unstarted if self.unstarted?
      return :in_progress if self.in_progress?
      return :finished if self.finished?
      return :postponed if self.postponed?
    end

    def unstarted?
      @interval.empty? && ! self.finished?
    end

    def in_progress?
      @interval[0] && ! self.finished?
    end

    def finished?
      self.tags.include?(:done) || (@interval[0] && @interval[1])
    end

    def postponed?
      self.tags.include?(:postponed)
    end

    def remaining_duration(current_time_frame)
      @interval[0] || raise("The task #{self.inspect} hasn't been started yet.")

      closing_time = @interval[0] + duration
      interval_end_time = current_time_frame.interval[1]
      # TODO: osetrit tohle:
      # - [8:30-now] Work on Pomodoro. #done
    end
  end
end
