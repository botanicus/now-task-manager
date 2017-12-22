require 'spec_helper'
require 'ostruct'
require 'date'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Config do
  describe '.help' do
    it "has it" do
      expect(described_class).to respond_to(:help)
      expect(described_class.help.length).not_to be(0)
    end
  end

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  let(:config) do
    Pomodoro::Config.new('spec/data/now-task-manager.yml')
  end

  let(:args) { Array.new }

  context "with no arguments" do
    it "prints out the whole config" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0].keys[0]).to eql(:p)
    end
  end

  context "with a key" do
    let(:args) { ['today_path'] }

    it "prints out its value" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0][:stdout]).to match("/#{Date.today.strftime('%Y-%m-%d')}.today")
    end
  end

  context "with a key and an argument" do
    let(:args) { ['today_path', '2015-01-31'] }

    it "prints out its value" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0][:stdout]).to match("/2015-01-31.today")
    end
  end
end
