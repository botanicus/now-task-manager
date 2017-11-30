require 'yaml'

module Pomodoro
  class Config
    CONFIG_PATH ||= File.expand_path('~/.config/pomodoro.yml')

    def initialize
      @data ||= YAML.load_file(CONFIG_PATH)
    rescue
      @data ||= Hash.new
    end

    {
      task_list: '~/pomodoro/tasks.todo',
      today: '~/pomodoro/%Y-%m-%d.today',
      schedule: '~/pomodoro/schedule.rb',
      routine: '~/pomodoro/routine.rb'
    }.each do |key, default_value|
      define_method(:"#{key}_path") do
        path = @data[key.to_s] || default_value
        path = File.expand_path(Time.now.strftime(path))
        if File.exist?(path)
          path
        else
          raise "No #{key} found. Either create #{default_value} or add #{key} into #{CONFIG_PATH} pointing the the actual path."
        end
      end
    end
  end
end
