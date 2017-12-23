require 'yaml'

module Pomodoro
  def self.config
    @config ||= Config.new
  end

  class Config
    class ConfigFileMissingError < StandardError
      def initialize(config_path)
        super("The config file #{config_path.sub(ENV['HOME'], '~')} doesn't exist.")
      end
    end

    class ConfigError < StandardError
      def initialize(key)
        super("No such key: #{key}")
      end
    end

    CONFIG_PATH ||= File.expand_path('~/.config/now-task-manager.yml')

    # Use Pomodoro.config instead of instantiating a new Config object.
    def initialize(config_path = CONFIG_PATH)
      @config_path = config_path
    end

    def data
      @data ||= YAML.load_file(@config_path)
    rescue Errno::ENOENT
      raise ConfigFileMissingError.new(@config_path)
    end

    def inspect
      self.data && super
    end

    def data_root_path
      data_root_path = File.expand_path(self.data.fetch('data_root_path'))
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
        value = self.data.fetch(key.to_s) do
          raise ConfigError.new(key)
        end

        path = File.expand_path(time.strftime(value))
        if File.exist?(File.expand_path("#{path}/.."))
          path
        else
          dir, base = File.split(path)
          raise "#{self.class}##{key}: Root directory #{dir.sub(ENV['HOME'], '~')} for file #{base} doesn't exist..)"
        end
      end
    end

    def calendar
      (self.data['calendar'] || Hash.new).reduce(Hash.new) do |buffer, (event_name, date)|
        date = Date.strptime(date, '%d/%m')
        date = (date < Date.today) ? date.next_year : date
        buffer.merge(event_name => date)
      end
    end
  end
end
