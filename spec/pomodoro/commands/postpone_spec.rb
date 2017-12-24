require 'spec_helper'
require 'ostruct'
require 'timecop'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Postpone do
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)

  context "without today_path" do
    let(:config) do
      OpenStruct.new(today_path: 'non-existent.today')
    end

    it "fails" do
      run(subject)
      expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist.</red>\n  Run the <yellow>g</yellow> command first.")
    end
  end

  context "with a valid config" do
    let(:config) do
      OpenStruct.new(today_path: "spec/data/#{described_class}.#{rand(1000)}.today")
    end

    before(:each) do
      File.open(config.today_path, 'w') do |file|
        file.puts(data)
      end
    end

    after(:each) do
      File.unlink(config.today_path)
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
      context "with only reason provided" do
        it "postpones it for tomorrow" do
          $stdin = StringIO.new
          $stdin.write("I need XYZ first.\n\n")
          $stdin.rewind

          Timecop.freeze(Time.new(2017, 12, 23, 9)) do
            run(subject)

            expect(subject.sequence[0]).to eql(stdout: "<bold>Why?</bold> ")
            expect(subject.sequence[1]).to eql(stdout: "<bold>When do you want to review?</bold> Defaults to tomorrow. Format <yellow>%d/%m</yellow> ")
            expect(subject.sequence[2]).to eql(stdout: "<bold>~</bold> Task <green>active task</green> has been postponed to <yellow>24/12</yellow>.")
            expect(subject.sequence[3]).to eql(exit: 0)

            expect(File.read(config.today_path)).to eql("Admin (0:00 – 23:59)\n✘ [7:50-9:00] Active task.\n  Postponed: I need XYZ first.\n  Review at: 2017-12-24\n")
          end
        end
      end

      context "with reason and review date provided" do
        it "postpones it for tomorrow" do
          $stdin = StringIO.new
          $stdin.write("I need XYZ first.\n31/1\n")
          $stdin.rewind

          Timecop.freeze(h('9:00').to_time) do
            run(subject)

            expect(subject.sequence[0]).to eql(stdout: "<bold>Why?</bold> ")
            expect(subject.sequence[1]).to eql(stdout: "<bold>When do you want to review?</bold> Defaults to tomorrow. Format <yellow>%d/%m</yellow> ")
            expect(subject.sequence[2]).to eql(stdout: "<bold>~</bold> Task <green>active task</green> has been postponed to <yellow>31/1</yellow>.")
            expect(subject.sequence[3]).to eql(exit: 0)

            expect(File.read(config.today_path)).to eql("Admin (0:00 – 23:59)\n✘ [7:50-9:00] Active task.\n  Postponed: I need XYZ first.\n  Review at: 2017-01-31\n")
          end
        end
      end
    end

    context "with no active task" do
      let(:task) do
        'Unstarted task.'
      end

      it "aborts saying there is no task in progress" do
        run(subject)
        expect(subject.sequence[0]).to eql(abort: "<red>There is no task in progress.</red>")
      end
    end
  end
end
