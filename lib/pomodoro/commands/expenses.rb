# frozen_string_literal: true

require 'open-uri'
require 'json'
require 'pomodoro/formats/today/archive'

class Pomodoro::Commands::Expenses < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <green>expenses</green>
  EOF

  def rates
    @rates ||= Hash.new do |hash, currency|
      open("http://api.fixer.io/latest?base=#{currency}") do |stream|
        hash[currency] = JSON.parse(stream.read, symbolize_names: true)[:rates]
      end
    end
  end

  # convert from: 'USD', to: 'EUR', amount: 1
  # => 0.82884
  def convert(from:, to:, amount:)
    self.rates[from][to] * amount
  end

  def total(totals)
    totals.reduce(0) do |sum, (currency, amount)|
      sum + convert(from: currency, to: :EUR, amount: amount)
    end
  end

  def run
    # week, month
    today = Date.today
    monday = today - (today.wday - 1) % 7
    archive = Pomodoro::Formats::Today::Archive.new(monday, today)
    archive.days.each do |day|
      totals = day.review.expenses.data.totals.map { |key, value| "<yellow>#{key}</yellow> #{value}" }.join(', ')
      total = total(day.review.expenses.data.totals)
      puts "<green>#{day.date.strftime('%a %-d/%-m')}</green> #{totals} = <blue.bold>EUR</blue.bold> #{total.round(2)}"
    end

    overall_totals = archive.days.reduce(Hash.new { |hash, key| hash[key] = 0 }) do |sums, day|
      day.review.expenses.data.totals.each do |key, value|
        sums[key] += value
      end

      sums
    end

    overall_total = archive.days.reduce(0) do |sum, day|
      sum + total(day.review.expenses.data.totals)
    end

    overall_totals = overall_totals.map { |key, value| "<yellow>#{key}</yellow> #{value}" }.join(', ')
    puts "\n<green>Overall</green> #{overall_totals} = <blue.bold>EUR</blue.bold> #{overall_total.round(2)}"
    puts "<green>Daily average</green> <blue.bold>EUR</blue.bold> #{(overall_total / archive.days.length).round(2)}"
  end
end
