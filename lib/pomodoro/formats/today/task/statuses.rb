module Pomodoro::Formats::Today
  module TaskStatuses
    # @!group Status checking methods
    def status_x
      if self.unstarted? then :unstarted
      # elsif self.skipped? then :skipped
      elsif self.ended? then :ended
      elsif self.in_progress? then :in_progress
      elsif self.completed? then :completed
      elsif self.progress_made_but_not_finished? then :progress_made_but_not_finished
      elsif self.postponed? then :postponed
      elsif self.deleted? then :deleted
      end
    end

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
      @start_time = Hour.now
    end

    def finish_for_the_day!
      @end_time = Hour.now if @start_time
      @status = :done
    end

    def complete!
      @end_time = Hour.now if @start_time
      @status = :done
    end

    def postpone!(reason, next_review = (Date.today + 1).strftime('%Y/%m/%d'))
      @end_time = Hour.now if @start_time
      @status = :failed
      @lines << "Postponed: #{reason}"
      # TODO: Add year if it's not the current one.
      next_review_date = Date.parse(next_review) # FIXME: a/b je b/a!
      next_review_date_str = (next_review_date.year == Date.today.year) ? next_review_date.strftime('%-d/%-m') : next_review_date.strftime('%-d/%-m/%Y')
      @lines << "Review at: #{next_review_date_str}"
    end

    def fail!(reason)
      @end_time = Hour.now if @start_time
      @status = :failed
      @lines << "Not done: #{reason}"
    end
  end
end
