require 'pomodoro/exts/hour'
require 'pomodoro/formats/today'
require 'pomodoro/formats/today/metadata'

module Pomodoro::Formats::Today
  class Task
    def unstarted?
      @start_time.nil?
    end

    def skipped?(time_frame)
      self.unstarted? && time_frame.end_time > Hour.parse(Time.now.strftime('%H:%M'))
    end

    def in_progress?
      ! @start_time.nil? && @end_time.nil?
    end

    def completed?
      @status == :finished && ! @lines['Postponed']
    end

    STATUS_SYMBOLS ||= {
      # Unfinished statuses.
      # Unstarted can be either tasks to be started,
      # or tasks skipped when time frame changed.
      unstarted: '-', in_progress: '-',

      # skipped: on switch of time frames
      # maybe status :finished and :unfinished, but :unfinished would require Postponed/Deleted etc. (check dynamically)
      # changing start_time for [9:20] to fixed_start_time would make some checks easier.
      #
      # ALL THE FINISHED STATUSES SHOULD BE EITHER ✔ or ✘

      # Finished, as in done for the day.
      completed: '✔', progress_made: '✔', postponed: '✘', deleted: '✘'
    }

    attr_reader :status, :desc, :duration, :start_time, :end_time, :fixed_start_time, :tags
    def initialize(desc:, start_time: nil, end_time: nil, fixed_start_time: nil, duration: nil, status:, tags: [], lines: [])
      @desc, @status, @tags = desc, status, tags || Array.new
      @start_time, @end_time, @fixed_start_time, @duration = start_time, end_time, fixed_start_time, duration

      @start_time && (@start_time.is_a?(Hour) || raise(ArgumentError.new("start_time has to be an Hour instance.")))
      @end_time && (@end_time.is_a?(Hour) || raise(ArgumentError.new("end_time has to be an Hour instance.")))
      @fixed_start_time && (@fixed_start_time.is_a?(Hour) || raise(ArgumentError.new("fixed_start_time has to be an Hour instance.")))

      if @start_time.nil? && @end_time
        raise ArgumentError.new("Setting end_time without start_time is invalid.")
      end

      if @start_time && @end_time && @start_time >= @end_time
        raise ArgumentError.new("start_time has to be smaller than end_time.")
      end

      if @duration && ! (@duration.respond_to?(:integer?) && @duration.integer?)
        raise ArgumentError.new("Duration has to be an integer.")
      end

      if @duration && ! (5..90).include?(@duration)
        raise ArgumentError.new("Duration has between 5 and 90 minutes.")
      end

      unless STATUS_SYMBOLS.keys.include?(@status)
        raise ArgumentError.new("Status has to be one of #{STATUS_SYMBOLS.keys.inspect}.")
      end

      # This is actually valid as in [9:20] Call Julia.
      #
      # if @status == :unstarted && @start_time
      #   raise ArgumentError.new("Make up your mind! Has the task been started or not?")
      # end

      if self.unfinished? && @end_time
        raise ArgumentError.new("An unstarted task cannot have an end_time.")
      end
    end

    # Dynamically defined.
    attr_accessor :command

    def to_s
      output = [STATUS_SYMBOLS[self.status]]
      if @start_time || @end_time
        output << "[#{self.class.format_interval(@start_time, @end_time)}]"
      else
        output << "[#{@duration}]" unless @duration == DEFAULT_DURATION
      end
      output << @desc
      output << @tags.map { |tag| "##{tag}"}.join(' ') unless @tags.empty?
      output.join(' ')
    end

    def start!
      @status, @start_time = :in_progress, Hour.now
    end

    def finish_for_the_day!
      @end_time = Hour.now if @start_time
      @status = :progress_made
    end

    def complete!
      @end_time = Hour.now if @start_time
      @status = :completed
    end

    def postpone!(reason, next_review)
      @end_time = Hour.now if @start_time
      @status = :postponed
    end

    def delete!(reason)
      @end_time = Hour.now if @start_time
      @status = :postponed
    end

    # Status checks.
    def unfinished?
      [:unstarted, :in_progress].include?(@status)
    end

    def finished?
      ! self.unfinished?
    end
    # unstarted: '-', in_progress: '-',
    # progress_made: '-', postponed: '✘', deleted: '✘'

    def completed?
      @status == :completed
    end

    def uncompleted?
      ! self.completed?
    end

    def postponed?
      self.tags.include?(:postponed)
    end

    def remaining_duration(current_time_frame)
      @start_time || raise("The task #{self.inspect} hasn't been started yet.")

      closing_time = @start_time + duration
      interval_end_time = current_time_frame.interval[1]
    end

    protected
    def format_duration
      if @start_time && @end_time
        [@start_time, @end_time].join('-')
      elsif @start_time
        "started at #{@start_time}"
      elsif @end_time
        raise 'nonsense'
      else # nil
      end
    end
  end
end
