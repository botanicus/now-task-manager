# frozen_string_literal: true

require 'yaml'
require 'pomodoro/locale'

module Pomodoro
  def self.config
    @config ||= Config.new
  end

  class Config
    class ConfigError < StandardError
    end

    class ConfigFileMissingError < ConfigError
      def initialize(config_path)
        super(
          I18n.t(
            'errors.config.missing_file',
            path: RR::Homepath.new(config_path).to_s))
      end
    end

    class MissingKeyError < ConfigError
      def initialize(key)
        super(I18n.t('errors.config.missing_key', key: key))
      end
    end

    CONFIG_PATH ||= File.expand_path('~/.config/now-task-manager.yml')

    # Use Pomodoro.config instead of instantiating a new Config object.
    attr_reader :path
    def initialize(path = CONFIG_PATH)
      @path = path
    end

    def data
      @data ||= YAML.load_file(@path)
    rescue Errno::ENOENT
      raise ConfigFileMissingError.new(@path)
    end

    def inspect
      self.data && super
    end

    def data_root_path(*chunks)
      data_root_path = File.expand_path(self.data.fetch('data_root_path'))
      if File.directory?(data_root_path)
        [data_root_path, *chunks].join('/')
      else
        raise ConfigError.new("data_root_path was supposed to be #{data_root_path}, but such path doesn't exist.")
      end
    end

    [
      :task_list_path, :today_path, :schedule_path, :routine_path
    ].each do |key|
      define_method(:"#{key}_dir") do |time = Time.now|
        value = self.data.fetch(key.to_s) do
          raise MissingKeyError.new(key)
        end

        File.expand_path("#{time.strftime(value)}/..")
      end

      define_method(key) do |time = Time.now|
        value = self.data.fetch(key.to_s) do
          raise MissingKeyError.new(key)
        end

        path = File.expand_path(time.strftime(value))
        if File.exist?(File.expand_path("#{path}/.."))
          path
        else
          dir, base = File.split(path)
          raise ConfigError.new("#{self.class}##{key}: Root directory #{RR::Homepath.new(dir)} for file #{base} doesn't exist..)")
        end
      end
    end

    def calendar
      (self.data['calendar'] || Hash.new).reduce(Hash.new) do |buffer, (event_name, date)|
        if date.is_a?(Integer)
          today = Date.today
          p_date = Date.new(today.year, today.month, date)
          date = today.day > date ? p_date.next_month : p_date
        else
          date = Date.strptime(date, '%d/%m')
          date = (date < Date.today) ? date.next_year : date
        end
        buffer.merge(event_name => date)
      end
    end
  end
end
