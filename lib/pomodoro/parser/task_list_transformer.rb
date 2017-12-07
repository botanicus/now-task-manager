require 'parslet'

module Pomodoro
  module SimpleFormat
    class TaskList
      attr_reader :data
      def initialize(data)
        @data = data
      end

      def [](label)
        @data.find do |task_group|
          task_group.name == label
        end
      end

      def delete(task_group)
        @data.delete(task_group)
      end

      def []=(label, tasks)
        @data << TaskGroup.new(name: label, tasks: tasks)
      end

      include Enumerable
      def each(&block)
        @data.each(&block)
      end

      def to_s
        @data.map(&:to_s).join("\n")
      end

      def save(path)
        data = self.to_s
        File.open(path, 'w') do |file|
          file.puts(data)
        end
      end
    end

    class TaskGroup
      attr_reader :name, :tasks
      def initialize(name:, tasks: Array.new)
        @name, @tasks = name, tasks
      end

      def <<(task)
        @tasks << task
      end

      def delete(task)
        @tasks.delete(task)
      end

      def to_s
        [@name, @tasks.map { |task| "- #{task}" }, nil].flatten.join("\n")
      end
    end

    class TaskListTransformer < Parslet::Transform
      rule(task: simple(:task)) { task.to_s }
      rule(task_group_header: simple(:header)) { header.to_s } # Doesn't work. Has multiple keys by the way.

      rule(task_group: subtree(:task_group)) {
        SimpleFormat::TaskGroup.new(name: task_group[:task_group_header].to_s, tasks: task_group[:task_list])
      }
    end
  end
end
