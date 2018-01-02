require 'pomodoro/formats/today/archive'

class Pomodoro::Commands::Consumption < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>consumption</green>
  EOF

  def run
    today = Date.today
    monday = today - (today.wday - 1) % 7
    archive = Pomodoro::Formats::Today::Archive.new(monday, today)
    archive.days.each do |day|
      total = day.review.consumption.data.sum
      puts "<green>#{day.date.strftime('%a %-d/%-m')}</green> #{total.round(2)}"
    end

    total = archive.days.reduce(0) { |sum, day| sum + day.review.consumption.data.sum }
    puts "\n<green>Overall</green> #{total.round(2)}"
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
