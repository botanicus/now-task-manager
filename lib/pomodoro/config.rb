require 'yaml'

module Pomodoro
  def self.config
    @config ||= Config.new
  end

  class Config
    CONFIG_PATH ||= File.expand_path('~/.config/now-task-manager.yml')

    # Use Pomodoro.config instead of instantiating a new Config object.
    def initialize
      @data = YAML.load_file(CONFIG_PATH)
    rescue
      @data = Hash.new
    end

    def data_root_path
      data_root_path = File.expand_path(@data.fetch('data_root_path'))
      if File.directory?(data_root_path)
        data_root_path
      else
        raise "data_root_path was supposed to be #{data_root_path}, but such path doesn't exist."
      end
    end

    [
      :task_list_path, :today_path, :schedule_path, :routine_path
    ].each do |key|
      define_method(key) do |time = Time.now|
        path = File.expand_path(time.strftime(@data[key.to_s]))
        if File.exist?(File.expand_path("#{path}/.."))
          path
        else
          raise "No #{key} found. Add #{key} into #{CONFIG_PATH} pointing the the actual path."
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
