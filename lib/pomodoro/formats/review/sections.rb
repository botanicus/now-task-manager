class Pomodoro::Formats::Review::Sections
  attr_reader :sections
  def initialize(sections)
    @sections = sections

    section_methods = [:method_name]
    unless sections.is_a?(Array) && sections.all? { |item| section_methods.all? { |method| item.respond_to?(method) }}
      raise ArgumentError.new("Sections is supposed to be an array of section-like instances, was #{@sections.inspect}.")
    end

    sections.each do |section|
      self.define_singleton_method(section.method_name) do
        section
      end
    end
  end

  def <<(time_frame)
    self.define_singleton_method(section.method_name) do
      section
    end

    @sections << section
  end
end
