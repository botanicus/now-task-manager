require 'spec_helper'
require 'ostruct'
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
      expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist</red>")
    end
  end

  context "with a valid config" do
    let(:task) do
      '[7:50-???] [20] Active task.'
    end

    let(:data) do
      <<-EOF.gsub(/^\s*/, '')
        Admin (0:00 – #{time_frame_end_time})
        - #{task}
        - Active task.
      EOF
    end

    context "and a next task" do
    end

    context "and no next task" do
    end
  end
end
