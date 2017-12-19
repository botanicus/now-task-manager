require 'date'

module Pomodoro::Formats::Scheduled
  class TaskGroup
    # @since 1.0
    attr_reader :header, :tasks

    # @param header [String] header of the task group.
    # @param tasks [Array<String>] tasks of the group.
    # @since 1.0
    #
    # @example
    #   require 'pomodoro/formats/scheduled'
    #
    #   tasks = ['Buy milk. #errands', '[9:20] Call with Mike.']
    #   group = Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Tomorrow', tasks: tasks)
    def initialize(header:, tasks: Array.new)
      @header, @tasks = header, tasks
    end

    # Add a task to the task group.
    #
    # @since 1.0
    def <<(task)
      @tasks << task unless @tasks.include?(task)
    end

    # Remove a task from the task group.
    #
    # @since 1.0
    def delete(task)
      @tasks.delete(task)
    end

    # Return a scheduled task list formatted string.
    #
    # @since 1.0
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
      return Date.today + 1 if @header == 'Tomorrow'
      return Date.parse(@header)
    rescue ArgumentError
    end

    def tomorrow?
      self.scheduled_date == Date.today + 1
    end
  end
end
