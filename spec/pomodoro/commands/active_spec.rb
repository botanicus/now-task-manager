require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Active do
  let(:config) do
    OpenStruct.new(today_path: 'spec/data/tasks/2017/12/2017-12-20.today')
  end

  context "with no active task" do
    subject do
      described_class.new([], config).extend(CLITestHelpers)
    end

    it "prints out the active task" do
      expect { subject.run }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0][:p]).to be_kind_of(Pomodoro::Formats::Today::Task)
    end
  end

  context "with an active task" do
    subject do
      described_class.new([], config)
    end

    it "exits with 1" do
      # TODO
    end
  end
end
