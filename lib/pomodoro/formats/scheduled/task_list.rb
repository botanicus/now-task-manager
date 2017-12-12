module Pomodoro::Formats::Scheduled
  class TaskList
    include Enumerable

    # List of {TaskGroup task groups}. Or more precisely objects responding to `#header` and `#tasks`.
    # @since 1.0
    attr_reader :data

    # @param [Array<TaskGroup>] data List of task groups.
    #   Or more precisely objects responding to `#header` and `#tasks`.
    # @raise [ArgumentError] if data is not an array or if its content doesn't
    #   respond to `#header` and `#tasks`.
    #
    # @example
    #   require 'pomodoro/formats/scheduled'
    #
    #   tasks = ['Buy milk. #errands', '[9:20] Call with Mike.']
    #   group = Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Tomorrow', tasks: tasks)
    #   list  = Pomodoro::Formats::Scheduled::TaskList.new([group])
    # @since 1.0
    def initialize(data)
      @data = data

      unless data.is_a?(Array) && data.all? { |item| item.respond_to?(:header) && item.respond_to?(:tasks) }
        raise ArgumentError.new("Data is supposed to be an array of TaskGroup instances.")
      end
    end

    # Find a task group that matches given header.
    #
    # @return [TaskGroup, nil] matching the header.
    # @since 1.0
    #
    # @example
    #   # Using the code from the initialiser.
    #   list['Tomorrow']
    def [](header)
      @data.find do |task_group|
        task_group.header == header
      end
    end

    # Add a task group onto the task list.
    #
    # @raise [ArgumentError] if the task group is already in the list.
    # @param [TaskGroup] task_group the task group.
    # @since 1.0
    def <<(task_group)
      if self[task_group.header]
        raise ArgumentError.new("Task group with header #{task_group.header} is already on the list.")
      end

      @data << task_group
    end

    # Remove a task group from the task list.
    #
    # @param [TaskGroup] task_group the task group.
    # @since 1.0
    def delete(task_group)
      @data.delete(task_group)
    end

    # Iterate over the task groups.
    #
    # @yieldparam [TaskGroup] task_group
    # @since 1.0
    def each(&block)
      @data.each(&block)
    end

    # Return a scheduled task list formatted string.
    #
    # @since 1.0
    def to_s
      @data.map(&:to_s).join("\n")
    end

    def save(path)
      data = self.to_s
      File.open(path, 'w:utf-8') do |file|
        file.puts(data)
      end
    end
  end
end
