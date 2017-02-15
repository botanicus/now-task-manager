require 'pomodoro/task'

module Pomodoro
  class TaskManager
    def self.load_tasks(task_list_path)
      hash = File.readlines(task_list_path).reduce(Hash.new) do |buffer, line|
        line.chomp!
        buffer.merge!(line[0..-2].downcase.to_sym => []) if line.match(/:$/)
        buffer[buffer.keys.last].push(Task.parse(line)) if line.match(/^- /)
        buffer
      end

      self.new(hash, task_list_path)
    end

    def initialize(tasks, task_list_path)
      @tasks, @task_list_path = tasks, task_list_path
    end

    def today_tasks
      @tasks[:today]
    end

    def mark_current_task_as_done
      first_task = self.today_tasks.find { |task| ! task.tags.include?(:done) }
      first_task.tags.push(:done)
      self.write_tasks
    end

    def write_tasks(stream = File.open(@task_list_path, 'w'))
      @tasks.each do |key, tasks|
        stream.puts "#{key.to_s.sub(/^\w/) { |m| m.upcase }}:"
        tasks.each do |task|
          stream.puts(task)
        end
        stream.puts unless @tasks.keys.last == key
      end
      stream.close if stream.is_a?(File) # unlike StringIO.
    end
  end
end
