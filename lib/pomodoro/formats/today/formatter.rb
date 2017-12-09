module Pomodoro::Formats::Today
  class Formatter
    STATUS_SYMBOLS ||= {
      # Unfinished statuses.
      # Unstarted can be either tasks to be started,
      # or tasks skipped when time frame changed.
      unstarted: '-', in_progress: '-',

      # maybe status :finished and :unfinished, but :unfinished would require Postponed/Deleted etc. (check dynamically)
      # Finished, as in done for the day.
      completed: '✔', progress_made: '✔', postponed: '✘', deleted: '✘'
    }

    def self.format(task)
      output = [STATUS_SYMBOLS[self.status]]
      if @start_time || @end_time
        output << "[#{self.class.format_interval(@start_time, @end_time)}]"
      else
        output << "[#{@duration}]" unless @duration == DEFAULT_DURATION
      end
      output << @body
      output << @tags.map { |tag| "##{tag}"}.join(' ') unless @tags.empty?
      output.join(' ')
    end
  end
end
