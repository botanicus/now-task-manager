require 'spec_helper'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Postpone do
  include_examples(:has_description)
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
      context "with only reason provided" do
        it "postpones it for tomorrow" do
          $stdin = StringIO.new
          $stdin.write("I need XYZ first.\n\n")
          $stdin.rewind

          Timecop.freeze(Time.new(2017, 12, 23, 9)) do
            run(subject)

            expect(subject.sequence[0]).to eql(stdout: "#{subject.t(:prompt_why)} ")
            expect(subject.sequence[1]).to eql(stdout: "#{subject.t(:prompt_when)} ")
            expect(subject.sequence[2]).to eql(stdout: subject.t(:success, task: 'active task', date: '24/12'))
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

            expect(subject.sequence[0]).to eql(stdout: "#{subject.t(:prompt_why)} ")
            expect(subject.sequence[1]).to eql(stdout: "#{subject.t(:prompt_when)} ")
            expect(subject.sequence[2]).to eql(stdout: subject.t(:success, task: 'active task', date: '31/1'))
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
