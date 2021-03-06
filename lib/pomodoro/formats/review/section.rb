# frozen_string_literal: true

class Pomodoro::Formats::Review::Section
  def self.plugins
    @plugins ||= Array.new
  end

  def self.register(plugin)
    self.plugins << plugin
  end

  attr_reader :header, :raw_data
  def initialize(header:, raw_data:)
    @header, @raw_data = header, raw_data

    raise ArgumentError unless header.is_a?(String)
  end

  def method_name
    @header.downcase.tr(' ', '_').to_sym
  end

  def plugin
    self.class.plugins.find do |plugin|
      self.header.match(plugin::HEADER)
    end
  end

  def data
    if self.plugin && self.raw_data.empty?
      Array.new
    elsif self.plugin
      self.plugin.parse("#{self.raw_data}\n")
    else
      self.raw_data
    end
  end
end
