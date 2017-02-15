require 'pomodoro/task'

module Pomodoro
  class TaskManager
    def self.parse(task_list_path)
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

    def tasks_for_later
      @tasks[:later]
    end

    def mark_active_task_as_done
      Time.now.strftime('%H:%M')
      self.active_task.tags.push(:done)
    end

    def active_task
      self.today_tasks.find { |task| ! task.tags.include?(:done) }
    end

    def add_task_for_later(task)
      @tasks[:later] << Task.new(task)
    end

    def finished_tasks
      self.today_tasks.select { |task| task.tags.include?(:done) }
    end

    def switch_days
      unfinished_tasks = @tasks[:today].select { |task| ! task.tags.include?(:done) }
      @tasks[:today] = @tasks[:template].dup
      placeholder = @tasks[:today].find { |task| task.text == '[content]' }
      position = @tasks[:today].index(placeholder)
      @tasks[:today].delete(placeholder)
      @tasks[:today].insert(position, *unfinished_tasks)
    end

    def save(stream = File.open(@task_list_path, 'w'))
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
