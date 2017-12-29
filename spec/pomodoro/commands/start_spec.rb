require 'spec_helper'
require 'ostruct'
require 'timecop'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Start do
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)
  include_examples(:requires_today_task_file)

  context "with a valid config", :valid_command do
    let(:config) do
      OpenStruct.new(today_path: "spec/data/#{described_class}.#{rand(1000)}.today")
    end

    let(:time_frame) do
      "Admin (0:00 – 23:59)"
    end

    let(:task) do
      '[7:50-???] Active task.'
    end

    let(:data) do
      [
        time_frame,
        (['-', task].join(' ') if task)
      ].compact.join("\n")
    end

    context "with an active task" do
      it "aborts saying there is an active task already" do
        run(subject)
        expect(subject.sequence[0]).to eql(abort: "<red>There is an active task already:</red> active task.")
      end
    end

    context "with no active task" do
      let(:task) do
        'Unstarted task.'
      end

      it "starts it" do
        Timecop.freeze(h('9:00').to_time) do
          run(subject)

          expect(subject.sequence[0]).to eql(stdout: "<bold>~</bold> Task <green>unstarted task</green> has been started.")
          expect(subject.sequence[1]).to eql(exit: 0)

          expect(File.read(config.today_path)).to eql("Admin (0:00 – 23:59)\n- [9:00-????] Unstarted task.\n")
        end
      end
    end
  end
end
