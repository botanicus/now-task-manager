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
      task_list_path: '~/pomodoro/tasks.todo',
      today_path: '~/pomodoro/%Y-%m-%d.today',
      schedule_path: '~/pomodoro/schedule.rb',
      routine_path: '~/pomodoro/routine.rb',
      data_root_path: nil
    }.each do |key, default_value|
      define_method(key) do |time = Time.now|
        path = @data[key.to_s] || default_value
        path = File.expand_path(time.strftime(path))
        if File.exist?(File.expand_path("#{path}/.."))
          path
        else
          raise "No #{key} found. Either create #{default_value} or add #{key} into #{CONFIG_PATH} pointing the the actual path."
        end
      end
    end

    def calendar
      (@data['calendar'] || Hash.new).reduce(Hash.new) do |buffer, (event_name, date)|
        date = Date.strptime(date, '%d/%m')
        date = (date < Date.today) ? date.next_year : date
        buffer.merge(event_name => date)
      end
    end
  end
end
