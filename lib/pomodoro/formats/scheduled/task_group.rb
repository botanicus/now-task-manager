require 'date'

module Pomodoro::Formats::Scheduled
  class TaskGroup
    # @since 0.2
    attr_reader :header, :tasks

    # @param header [String] header of the task group.
    # @param tasks [Array<String>] tasks of the group.
    # @since 0.2
    #
    # @example
    #   require 'pomodoro/formats/scheduled'
    #
    #   tasks = ['Buy milk. #errands', '[9:20] Call with Mike.']
    #   group = Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Tomorrow', tasks: tasks)
    def initialize(header:, tasks: Array.new)
      @header, @tasks = header, tasks
      if tasks.any? { |task| ! task.is_a?(Task) }
        raise ArgumentError.new("Task objects expected.")
      end
    end

    # Add a task to the task group.
    #
    # @since 0.2
    def <<(task)
      unless task.is_a?(Task)
        raise ArgumentError.new("Task expected, got #{task.class}.")
      end

      @tasks << task unless @tasks.map(&:to_s).include?(task.to_s)
    end

    # Remove a task from the task group.
    #
    # @since 0.2
    def delete(task)
      unless task.is_a?(Task)
        raise ArgumentError.new("Task expected, got #{task.class}.")
      end

      @tasks.delete_if { |t2| t2.to_s == task.to_s }
    end

    # Return a scheduled task list formatted string.
    #
    # @since 0.2
    def to_s
      [@header, @tasks.map(&:to_s), nil].flatten.join("\n")
    end

    def save(path)
      data = self.to_s
      File.open(path, 'w:utf-8') do |file|
        file.puts(data)
      end
    end

    # labels = ['Tomorrow', date.strftime('%A'), date.strftime('%-d/%m'), date.strftime('%-d/%m/%Y')]
    def scheduled_date
      return Date.today if @header == 'Today' # Change tomorrow to Today if you're generating it in the morning.
      return Date.today + 1 if @header == 'Tomorrow'
      ['%A %d/%m', '%d/%m', '%A'].each do |format|
        begin
          return Date.strptime(@header, format)
        rescue ArgumentError
        end
      end
    end

    def tomorrow?
      self.scheduled_date == Date.today + 1
    end
  end
end
