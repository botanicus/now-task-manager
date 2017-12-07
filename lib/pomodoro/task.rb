require 'pomodoro/exts/hour'

module Pomodoro
  class Task
    DEFAULT_DURATION = 10

    def self.format_interval(start_time, finish_time)
      if start_time && finish_time
        [start_time, finish_time].join('-')
      elsif start_time
        "started at #{start_time}"
      elsif finish_time
        raise 'nonsense'
      else # nil
      end
    end

    attr_reader :status, :text, :duration, :start_time, :end_time, :tags
    def initialize(desc:, status: :initial, start_time: nil, end_time: nil, duration: nil, tags: [], lines: [])
      @text, @duration, @tags = desc, duration || DEFAULT_DURATION, tags || Array.new
      @start_time, @end_time = start_time, end_time
    end

    STATUS_SYMBOLS ||= {finished: '✔', not_done: '✘', postponed: '✘', unstarted: '-', in_progress: '-'}
    def to_s
      output = [STATUS_SYMBOLS[self.status]]
      if @start_time || @end_time
        output << "[#{self.class.format_interval(@start_time, @end_time)}]"
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
      @start_time = Hour.now
    end

    def finish
      if @start_time
        @end_time = Hour.now
      else
        @status = :finished
      end
    end

    def status
      return :unstarted if self.unstarted?
      return :in_progress if self.in_progress?
      return :finished if self.finished?
      return :postponed if self.postponed?
      return :failed # ...
    end

    def unstarted?
      ! @start_time && ! self.finished?
    end

    def in_progress?
      @start_time && ! self.finished?
    end

    def finished?
      (@start_time && @end_time) || @status == :finished
    end

    def postponed?
      self.tags.include?(:postponed)
    end

    def remaining_duration(current_time_frame)
      @start_time || raise("The task #{self.inspect} hasn't been started yet.")

      closing_time = @start_time + duration
      interval_end_time = current_time_frame.interval[1]
    end
  end
end
