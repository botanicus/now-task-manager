module Pomodoro::Formats::Scheduled
  class TaskGroup
    # @since 1.0
    attr_reader :name, :tasks

    # @param name [String] label of the task group.
    # @param tasks [Array<String>] tasks of the group.
    # @since 1.0
    #
    # @example
    #   require 'pomodoro/formats/scheduled'
    #
    #   tasks = ['Buy milk. #errands', '[9:20] Call with Mike.']
    #   group = Pomodoro::Formats::Scheduled::TaskGroup.new(name: 'Tomorrow', tasks: tasks)
    def initialize(name:, tasks: Array.new)
      @name, @tasks = name, tasks
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
      [@name, @tasks.map { |task| "- #{task}" }, nil].flatten.join("\n")
    end
  end
end
