require 'pomodoro/task'
require 'pomodoro/time_frame'
require 'pomodoro/scheduler'

module Pomodoro
  class TaskManager
    # This returns an array of tasks without any time frames.
    # This is used for the upcoming days and context (such as CZ), not for today.
    def self.parse(task_list_path)
      hash = File.readlines(task_list_path, encoding: 'utf-8').reduce(Hash.new) do |buffer, line|
        line.chomp!
        buffer.merge!(line[0..-2].downcase.to_sym => []) if line.match(/:$/) #line.match(/^[^-#].+\(.+\)/)
        buffer[buffer.keys.last].push(Task.parse(line)) if line.match(/^- /)
        buffer
      end

      self.new(hash, task_list_path)
    end

    def initialize(tasks, task_list_path)
      @tasks, @task_list_path = tasks, task_list_path
    end

    def tasks_for_later
      @tasks[:later]
    end

    def add_task_for_later(task)
      @tasks[:later] << Task.new(task)
    end

    def switch_days(tomorrow, schedule)
      unfinished_tasks = @tasks[:today].select { |task| ! task.tags.include?(:done) }

      @tasks[:today] = Scheduler.load(schedule, tomorrow).for_today
      unfinished_tasks.delete_if { |task| @tasks[:today].any? { |task2| task.text == task2.text } }

      tasks_for_tomorrow = (tomorrow.sunday?) ? [] : (@tasks[:tomorrow] || [])

      # Parse dates like "Wednesday", "1/1", "Wednesday 1/1" etc.
      @tasks.keys.each do |key|
        date = Date.parse(key.to_s) rescue nil
        if date && date == tomorrow
          tasks_for_tomorrow.push(*@tasks[key])
          @tasks.delete(key)
        end
      end

      first_personal_item = @tasks[:today].find do |task|
        ! task.tags.include?(:morning_ritual) && ! task.tags.include?(:work)
      end

      position = @tasks[:today].index(first_personal_item) || @tasks[:today].length
      @tasks[:today].insert(position, *(unfinished_tasks + tasks_for_tomorrow))

      @tasks[:tomorrow] -= tasks_for_tomorrow if @tasks[:tomorrow]
    end

    def save(stream = File.open(@task_list_path, 'w'))
      raise "TODO"
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
