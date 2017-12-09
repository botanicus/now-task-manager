require 'spec_helper'
require 'pomodoro/formats/scheduled'

describe Pomodoro::Formats::Scheduled::TaskList do
  let(:data) do
    [Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Tomorrow')]
  end

  describe '.new' do
    it "accepts an empty array" do
      instance = described_class.new(Array.new)
      expect(instance.data).to be_empty
    end

    it "accepts an array of TaskGroup instances" do
      instance = described_class.new(data)
      expect(instance.data.length).to be(1)
    end

    it "does not accept anything but array" do
      expect { described_class.new(Hash.new) }.to raise_error(
        ArgumentError, /Data is supposed to be an array of TaskGroup instances/)
    end


    it "does not accept anything but array of TaskGroups" do
      expect { described_class.new([Hash.new]) }.to raise_error(
        ArgumentError, /Data is supposed to be an array of TaskGroup instances/)
    end
  end

  subject do
    described_class.new(data)
  end

  describe '#[]' do
    it "returns a task group matching the header" do
      expect(subject['Tomorrow'].header).to eql('Tomorrow')
    end

    it "returns nil if the header doesn't match any task group" do
      expect(subject['1/1/2018']).to be_nil
    end
  end

  describe '#<<' do
    it "adds a task group into the list" do
      task_group = Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Prague')
      expect { subject << task_group }.to change { subject.data.length }.by(1)
    end

    it "throws an error if task group with the same header is already in the list" do
      task_group = Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Tomorrow')
      expect { subject << task_group }.to raise_error(
        ArgumentError, /Task group with header Tomorrow is already on the list/)
    end
  end

  describe '#delete' do
    it "removes a task group from the list" do
      expect { subject.delete(data[0]) }.to change { subject.data.length }.by(-1)
    end
  end

  describe '#each' do
    it "returns an enumerator" do
      expect(subject.each).to be_kind_of(Enumerator)
    end
  end

  describe '#to_s' do
    let(:data) do
      [
        Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Tomorrow'),
        Pomodoro::Formats::Scheduled::TaskGroup.new(header: 'Prague', tasks: ["Pick up shoes #errands"])
      ]
    end

    it "returns a valid scheduled task list formatted string" do
      expect(subject.to_s).to eql("Tomorrow\n\nPrague\n- Pick up shoes #errands\n")
    end
  end
end
