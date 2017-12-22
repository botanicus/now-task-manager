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
      Pomodoro::Config.new('now-task-manager.yml')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>The config file ~/.config/now-task-manager.yml doesn't exist.</red>")
    end
  end

  context "without today_path" do
    let(:config) do
      OpenStruct.new(today_path: 'spec/data/tasks/1220/12/1220-12-20.today')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist</red>")
    end
  end

  context "with no active task" do
    it "exits with 1" do
      # TODO
    end
  end

  context "with an active task" do
    it "prints out the active task" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0][:p]).to be_kind_of(Pomodoro::Formats::Today::Task)
    end
  end
end
