require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Active do
  describe '.help' do
    it "has it" do
      expect(described_class).to respond_to(:help)
      expect(described_class.help.length).not_to be(0)
    end
  end

  let(:config) do
    OpenStruct.new(today_path: 'spec/data/tasks/2017/12/2017-12-20.today')
  end

  subject do
    described_class.new([], config).extend(CLITestHelpers)
  end

  context "without config" do
    let(:config) do
      Pomodoro::Config.new('non-existing-now-task-manager.yml')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>The config file ~/.config/now-task-manager.yml doesn't exist.</red>")
    end
  end

  context "without today_path" do
    let(:config) do
      OpenStruct.new(today_path: 'non-existin.today')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist</red>")
    end
  end

  context "with no active task" do
    let(:config) do
      OpenStruct.new(today_path: 'spec/data/1_basic.today')
    end

    it "exits with 1" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>! File spec/data/1_basic.today doesn't exist</red>")
    end
  end

  context "with an active task" do
    let(:config) do
      OpenStruct.new(today_path: 'spec/data/with_active_task.today')
    end

    it "prints out the active task" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0][:p]).to be_kind_of(Pomodoro::Formats::Today::Task)
    end
  end

  describe "formatters" do
    let(:config) do
      OpenStruct.new(today_path: 'spec/data/with_active_task.today')
    end

    subject do
      described_class.new([format_string], config).extend(CLITestHelpers)
    end

    describe "the body formatter %b" do
      let(:format_string) { '%b' }

      it "is described in help" do
        expect(described_class.help).to match(format_string)
      end

      it "displays the task body" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0]).to eql(stdout: "Active task.")
      end
    end

    describe "the start time formatter %s" do
      let(:format_string) { '%s' }

      it "is described in help" do
        expect(described_class.help).to match(format_string)
      end

      it "displays the task start time" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0]).to eql(stdout: "7:50")
      end
    end

    describe "the duration formatter %d" do
      let(:format_string) { '%d' }

      it "is described in help" do
        expect(described_class.help).to match(format_string)
      end

      context "it has duration" do
        it "displays the task duration" do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(stdout: "0:20")
        end
      end

      context "it doesn't have duration" do
        let(:config) do
          OpenStruct.new(today_path: 'spec/data/with_active_task_no_duration.today')
        end

        it "displays the task duration" do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(stdout: "")
        end
      end
    end

    describe "the remaining duration formatter %rd" do
      let(:format_string) { '%rd' }

      it "is described in help" do
        expect(described_class.help).to match(format_string)
      end

      context "it has duration" do
        it "displays the task duration" do
          pending "Use timecop or whatever is being used these days."
          raise
        end
      end

      context "it doesn't have duration" do
        let(:config) do
          OpenStruct.new(today_path: 'spec/data/with_active_task_no_duration.today')
        end

        it "displays the task duration" do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(stdout: "")
        end
      end
    end

    describe "the time frame formatter %tf" do
      let(:format_string) { '%tf' }

      it "is described in help" do
        expect(described_class.help).to match(format_string)
      end

      it "displays the task body" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0]).to eql(stdout: "Admin")
      end
    end
  end
end
