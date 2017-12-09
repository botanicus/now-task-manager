module Pomodoro::Formats::Today
  module TaskStatuses
    # @!group Status checking methods
    def ended?
      [:done, :failed].include?(@status)
    end

    def unstarted?
      @start_time.nil? && @status == :not_done
    end

    def skipped?(time_frame)
      self.unstarted? && time_frame.ended?
    end

    def in_progress?
      (! @start_time.nil? && @end_time.nil?) && @status == :not_done
    end

    alias_method :started?, :in_progress?

    def completed?
      @status == :done && ! self.metadata['Reason']
    end

    def progress_made_but_not_finished?
      @status == :done && self.metadata['Reason']
    end

    def postponed?
      @status == :failed && self.metadata['Postponed']
    end

    def deleted?
      @status == :failed && self.metadata['Deleted']
    end

    # @!group Status setters
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
      @status = :failed
    end

    def delete!(reason)
      @end_time = Hour.now if @start_time
      @status = :failed
    end
  end
end
