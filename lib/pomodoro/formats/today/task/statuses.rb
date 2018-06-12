# frozen_string_literal: true

module Pomodoro::Formats::Today
  module TaskStatuses
    # @!group Status checking methods
    def status_x
      if self.unstarted? then :unstarted
      # elsif self.skipped? then :skipped
      # elsif self.ended? then :ended
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

    def reset!
      @start_time = nil
    end

    def postpone!(reason, next_review_date = Date.today + 1)
      unless next_review_date.is_a?(Date)
        raise ArgumentError.new("Date expected, got #{next_review_date} (#{next_review_date.class}).")
      end

      @end_time = Hour.now if @start_time
      @status = :failed
      @lines << "Postponed: #{reason}"
      @lines << "Review at: #{next_review_date.iso8601}"

      next_review_date
    end

    def fail!(reason)
      @end_time = Hour.now if @start_time
      @status = :failed
      @lines << "Not done: #{reason}"
    end
  end
end
