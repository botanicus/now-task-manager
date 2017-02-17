class Hour
  attr_reader :minutes
  def initialize(hours, minutes = 0)
    @minutes = (hours * 60) + minutes
  end

  def +(hour)
    self.class.new(0, @minutes + hour.minutes)
  end

  def hours
    if (@minutes / 60).round > (@minutes / 60)
      (@minutes / 60).round - 1
    else
      (@minutes / 60).round
    end
  end

  # Currently unused, but it might be in the future.
  # def *(rate)
  #   (@minutes * (rate / 60.0)).round(2)
  # end

  [:==, :eql?, :<, :<=, :>, :>=].each do |method_name|
    define_method(method_name) do |anotherHour|
      self.minutes.send(method_name, anotherHour.minutes)
    end
  end

  def inspect
    "#{self.hours}:#{format('%02d', self.minutes_over_the_hour)}"
  end
  alias_method :to_s, :inspect

  protected
  def minutes_over_the_hour
    @minutes - (self.hours * 60)
  end
end
