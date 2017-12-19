require 'date'
require 'pomodoro/formats/today'
require 'pomodoro/config'

module Pomodoro::Formats::Today
  class Day
    def self.for(date)
      path = Pomodoro.config.today_path(date)
      Pomodoro::Formats::Today.parse(File.open(path, encoding: 'utf-8'))
    rescue Errno::ENOENT
    end

    attr_reader :path, :task_list
    def initialize(path: nil, nodes: Array.new)
      @path, @nodes = path, nodes
    end

    def date
      Date.parse(self.path.match(/\d{4}-\d{2}-\d{2}/)[0]) if self.path
    end

    def tags
      @tags ||= if @nodes.first.is_a?(TimeFrame) || @nodes.first.nil?
        Array.new
      else
        @nodes.first
      end
    end

    def task_list
      @task_list ||= if @nodes.first.is_a?(TimeFrame)
        TaskList.new(*@nodes)
      else
        TaskList.new(*@nodes[1..-1])
      end
    end

    def empty?
      self.tags.empty? && self.task_list.time_frames.empty?
    end

    def normal?
      ([:holidays, :bedbound] & self.tags).empty?
    end
  end
end
