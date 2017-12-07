require 'pomodoro/task'
require 'pomodoro/exts/hour'

module Pomodoro
  class TimeFrame
    ALLOWED_OPTIONS ||= [:online, :writeable, :note, :tags]

    attr_reader :name, :tasks, :interval, :options
    attr_reader :start_time, :end_time, :desc
    def initialize(desc:, start_time: nil, end_time: nil, task_list: Array.new, **shit)
      # tag, interval_from, interval_to, options = Hash.new
      @name, @tag, @options = desc, nil, {}
      @interval = [start_time, end_time]
      @start_time, @end_time = start_time, end_time
      @desc = desc
      # @interval = [interval_from && Hour.parse(interval_from), interval_to && Hour.parse(interval_to)]
      @tasks = task_list

      # if @options.has_key?(:writeable) && ! @options[:writeable]
      #   @tasks.freeze
      # end

      unless (unrecognised_options = options.keys - ALLOWED_OPTIONS).empty?
        raise ArgumentError.new("Unrecognised options: #{unrecognised_options.inspect}")
      end
    end

    def create_task(desc, duration = nil, tags = Array.new)
      @tasks << Task.new(desc: desc, tags: tags)
    end

    def unshift_task(*args)
      @tasks.unshift(Task.new(*args))
    end

    def header
      if @interval[0] && @interval[1]
        [@name, "(#{@interval[0]} – #{@interval[1]})"].compact.join(' ')
      elsif @interval[0] && ! @interval[1]
        [@name, "(from #{@interval[0]})"].compact.join(' ')
      elsif ! @interval[0] && @interval[1]
        [@name, "(until #{@interval[1]})"].compact.join(' ')
      else
        [@name, @options[:online] && '#online'].compact.join(' ')
      end
    end

    def to_s
      if @tasks.empty?
        self.header
      else
        ["#{self.header}", self.tasks.map(&:to_s)].join("\n")
      end
    end

    def method_name
      if @name
        @name.downcase.tr(' ', '_').to_sym
      else
        :default
      end
    end

    def active_task
      self.tasks.find do |task|
        ! task.in_progress?
      end
    end

    def first_unstarted_task
      self.tasks.find do |task|
        task.unstarted?
      end
    end

    def remaining_duration
      @interval[1] && (@interval[1] - Hour.now)
    end

    include Enumerable
    def each(&block)
      @tasks.each do |task|
        block.call(task)
      end
    end

    def duration
      self.tasks.reduce(0) do |sum, task|
        (task.finished? && task.duration) ? sum + task.duration : sum
      end
    end

    # def has_unfinished_tasks?
    #   self.tasks.any? do |task|
    #     ! task.finished?
    #   end
    # end


    # def mark_active_task_as_done # TODO: WIP
    #   #Time.now.strftime('%H:%M')
    #   self.active_task.tags.push(:done)
    # end
    #
    # def active_task
    #   self.today_tasks.find { |task| ! task.tags.include?(:done) }
    # end
    #
    # def finished_tasks
    #   self.today_tasks.select { |task| task.tags.include?(:done) }
    # end
  end
end
