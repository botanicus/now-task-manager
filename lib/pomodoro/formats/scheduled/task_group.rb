# frozen_string_literal: true

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

    # TODO: Next Monday
    # NOTE: For parsing we don't use %-d etc, only %d.
    DATE_FORMATS = {
      '%d/%m'    => :next_month,    # 1/1
      '%d/%m/%Y' => nil,            # 1/1/2018
      '%A %d/%m' => :next_week,     # Monday 1/1  Note: Higher specifity has to come first.
      '%A'       => :next_week      # Monday
    }

    # labels = ['Tomorrow', date.strftime('%A'), date.strftime('%-d/%m'), date.strftime('%-d/%m/%Y')]
    def scheduled_date
      return Date.today if @header == 'Today' # Change tomorrow to Today if you're generating it in the morning.
      return Date.today + 1 if @header == 'Tomorrow'
      parse_date_in_the_future(@header)
    end

    def tomorrow?
      self.scheduled_date == Date.today + 1
    end

    private

    # TODO: We need base_date, Date.today wouldn't cut it if we run "now g +3".
    def parse_date_in_the_future(header)
      DATE_FORMATS.each do |format, adjustment_method|
        begin
          date = Date.strptime(header, format)
          date.define_singleton_method(:next_week) { self + 7 } # TODO: DataExts, extract it from commands.rb.
          return ensure_in_the_future(date, adjustment_method)
        rescue ArgumentError
        end
      end

      return nil
    end

    def ensure_in_the_future(date, adjustment_method)
      return date if adjustment_method.nil? || Date.today <= date
      date.send(adjustment_method)
    end
  end
end
