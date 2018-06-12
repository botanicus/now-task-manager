# frozen_string_literal: true

# 1/5/2018: specs complete, help complete.
class Pomodoro::Commands::Active < Pomodoro::Commands::Command
  class Formatter
    attr_reader :name, :pattern
    def initialize(name, pattern, &block)
      @name, @pattern, @block = name, pattern, block
    end

    def example
      Pomodoro::Commands::Active.t("examples.#{@name}")
    end

    def call(time_frame, active_task)
      block = @block || Proc.new { |_, t| t.send(@name) }
      block.call(time_frame, active_task)
    end
  end

  FORMATTERS ||= [
    Formatter.new(:body, '%B'),
    Formatter.new(:body_unsentenced, '%b') do |_, task|
      Pomodoro::Tools.unsentence(task.body)
    end,
    Formatter.new(:start_time, '%s'),
    Formatter.new(:duration, '%d'),
    Formatter.new(:remaining_duration, '%rd') do |time_frame, task|
      if task.duration
        result = task.remaining_duration(time_frame)
        result.minutes <= 0 ? 0 : result
      end
    end,
    Formatter.new(:time_frame, '%tf') do |time_frame, _|
      time_frame.name
    end
  ].freeze

  self.help = <<-EOF
    <bright_black># #{self.description}</bright_black>
    now <green>active</green>, now <green>active</green> [format string]
      #{FORMATTERS.map { |formatter|
        "<red>#{formatter.pattern}</red> #{formatter.name} <bright_black># For example: #{formatter.example}</bright_black>"
      }.join("\n" + ' ' * 6)}
  EOF

  def run
    ensure_today
    today_list = parse_today_list(self.config).task_list

    active_task = today_list.active_task
    exit 1 unless active_task

    # The time frame is not necessarily current: if the task is marked as active,
    # but the time frame has ended, we still want to show both (or neither).
    time_frame = today_list.time_frames.find { |time_frame| time_frame.items.include?(active_task) }

    if format_string = @args.shift
      res = FORMATTERS.each_with_object(format_string.dup) do |formatter, format_string|
        if format_string.match?(formatter.pattern)
          value = formatter.call(time_frame, active_task)
          format_string.gsub!(formatter.pattern, value.to_s)
        end
      end

      puts res unless res == ''
    else
      p active_task
    end
  end
end
