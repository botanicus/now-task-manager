class Pomodoro::Commands::Tools < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
  EOF

  def run
    # TODO
    if ARGV.shift == 'workdays'
      start_date = Date.new(2018, 12, 1)
      end_date   = Date.new(2018, 12, 31)
      work_days = (start_date..end_date).reduce(0) do |sum, date|
        sum += 1 unless date.saturday? || date.sunday?; sum
      end
      puts "~ There are #{work_days} (without any bank holidays) in 2018."
      # TODO: Per-month breakdown.
    end
  end
end
