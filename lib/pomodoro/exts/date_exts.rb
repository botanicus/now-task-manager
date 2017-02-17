require 'date'

module DateExts
  def weekend?
    self.saturday? || self.sunday?
  end

  def weekday?
    ! self.weekend?
  end
end
