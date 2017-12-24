require 'spec_helper'
require 'ostruct'
require 'timecop'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Next do
  describe '.help' do
    it "has it" do
      expect(described_class).to respond_to(:help)
      expect(described_class.help.length).not_to be(0)
    end
  end

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  context "without config" do
    let(:config) do
      Pomodoro::Config.new('non-existent-now-task-manager.yml')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>The config file non-existent-now-task-manager.yml doesn't exist.</red>")
    end
  end

  context "without today_path" do
    let(:config) do
      OpenStruct.new(today_path: 'non-existent.today')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
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

    let(:active_task) do
      '[7:50-???] Active task.'
    end

    let(:coming_task) do
      'Upcoming task.'
    end

    let(:data) do
      [
        time_frame,
        (['-', active_task].join(' ') if active_task),
        (['-', coming_task].join(' ') if coming_task)
      ].compact.join("\n")
    end

    context "and an active task" do
      context "and a next task" do
        it "warns about the task in progress and prints out the upcoming one" do
          expect { run(subject) }.to change { subject.sequence.length }.by(2)
          expect(subject.sequence[0]).to eql(warn: "<yellow>There is a task in progress already:</yellow> active task.\n\n")
          expect(subject.sequence[1]).to eql(stdout: "<bold>~</bold> The upcoming task is <green>upcoming task</green>.")
        end
      end

      context "and no next task" do
        let(:coming_task) { }

        it "warns about the task in progress and prints out the upcoming one" do
          expect { run(subject) }.to change { subject.sequence.length }.by(2)
          expect(subject.sequence[0]).to eql(warn: "<yellow>There is a task in progress already:</yellow> active task.\n\n")
          expect(subject.sequence[1]).to eql(abort: "<red>No more tasks in Admin.</red>")
        end
      end

      context "and no active time frame" do
        let(:time_frame) do
          "Admin (9:00 – 9:59)"
        end

        it "warns about the task in progress and aborts saying there is no active time frame" do
          Timecop.freeze(h('10:00').to_time) do
            expect { run(subject) }.to change { subject.sequence.length }.by(2)
            expect(subject.sequence[0]).to eql(warn: "<yellow>There is a task in progress already:</yellow> active task.\n\n")
            expect(subject.sequence[1]).to eql(abort: "<red>There is no active time frame.</red>")
          end
        end
      end
    end

    context "and no active task" do
      let(:active_task) { }

      context "and a next task" do
        it "prints out the upcoming one" do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(stdout: "<bold>~</bold> The upcoming task is <green>upcoming task</green>.")
        end
      end

      context "and no next task" do
        let(:coming_task) { }

        it "aborts saying there are no more tasks" do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(abort: "<red>No more tasks in Admin.</red>")
        end
      end
    end

    context "and no active time frame" do
      let(:active_task) { }

      let(:time_frame) do
        "Admin (9:00 – 9:59)"
      end

      it "aborts saying there are no more tasks" do
        Timecop.freeze(h('10:00').to_time) do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(abort: "<red>There is no active time frame.</red>")
        end
      end
    end
  end
end
