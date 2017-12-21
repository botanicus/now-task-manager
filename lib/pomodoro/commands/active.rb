class Pomodoro::Commands::Active < Pomodoro::Commands::Command
  class Formatter
    attr_reader :name, :pattern
    def initialize(name, pattern, &block)
      @name, @pattern, @block = name, pattern, block
    end

    def call(time_frame, active_task)
      block = @block || Proc.new { |_, t| t.send(@name) }
      @block.call(time_frame, active_task)
    end
  end

  using RR::ColourExts

  FORMATTERS ||= [
    Formatter.new(:body, '%b'),
    Formatter.new(:start_time, '%s'),
    Formatter.new(:end_time, '%e'),
    Formatter.new(:duration, '%d'),
    Formatter.new(:remaining_duration, '%rd') do |time_frame, task|
      task.duration ? task.remaining_duration(time_frame) : nil
    end,
    Formatter.new(:time_frame, '%tf') do |time_frame, _|
      time_frame.name
    end
  ]

  self.help = <<-EOF
    <bright_black># Print the active task. Exit 1 if there is none.</bright_black>
    now <green>active</green>, now <green>active</green> [format string]
      #{FORMATTERS.map { |formatter| "<red>#{formatter.pattern}</red> #{formatter.name}" }.join("\n" + " " * 6)}
  EOF

  def run
    # exit 1
    must_exist(self.config.today_path)
    today_list = parse_today_list(self.config)

    active_task = today_list.active_task
    exit 1 unless active_task

    current_time_frame = today_list.current_time_frame

    if format_string = @args.shift
      puts(FORMATTERS.reduce(format_string.dup) do |format_string, formatter|
        if format_string.match(formatter.pattern)
          value = formatter.call(current_time_frame, active_task)
          format_string.gsub!(formatter.pattern, value.to_s)
        end
        format_string
      end)
    else
      p active_task
    end
  end
end
