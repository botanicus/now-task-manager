require 'pomodoro/task'
require 'pomodoro/exts/hour'

module Pomodoro
  class TimeFrame
    ALLOWED_OPTIONS ||= [:online, :writeable, :note, :tags]

    # # Morning ritual (7:50 – 9:30) #online:
    def self.parse(data)
      data.match(/^(.+)\((.+)\)( #online|):?\s*$/)
      name = $1.strip
      is_online = ($3.strip == '#online')
      case $2
      when /(\d+:\d+) – (\d+:\d+)/ then interval_from, interval_to = $1, $2
      when /from (\d+:\d+)/        then interval_from, interval_to = $1, nil end

      self.new(name, nil, interval_from, interval_to, online: is_online)
    end

    attr_reader :name, :tasks, :interval, :options
    def initialize(name, tag, interval_from, interval_to, options = Hash.new)
      @name, @tag, @options = name, tag, options
      @interval = [interval_from && Hour.parse(interval_from), interval_to && Hour.parse(interval_to)]
      @tasks = Array.new

      if @options.has_key?(:writeable) && ! @options[:writeable]
        @tasks.freeze
      end

      unless (unrecognised_options = options.keys - ALLOWED_OPTIONS).empty?
        raise ArgumentError.new("Unrecognised options: #{unrecognised_options.inspect}")
      end
    end

    def create_task(*args)
      @tasks << Task.new(*args)
    end

    def unshift_task(*args)
      @tasks.unshift(Task.new(*args))
    end

    def header
      if @interval[0] && @interval[1]
        [@name, "(#{@interval[0]} – #{@interval[1]})", @options[:online] && '#online'].compact.join(' ')
      elsif @interval[0] && ! @interval[1]
        [@name, "(from #{@interval[0]})", @options[:online] && '#online'].compact.join(' ')
      elsif ! @interval[0] && @interval[1]
        raise "I don't think this makes sense."
      else
        [@name, @options[:online] && '#online'].compact.join(' ')
      end
    end

    def to_s
      if @tasks.empty?
        self.header
      else
        ["#{self.header}:", self.tasks.map(&:to_s)].join("\n")
      end
    end

    def method_name
      if @name
        @name.downcase.tr(' ', '_').to_sym
      else
        :default
      end
    end


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
