require 'pomodoro/formats/scheduled'

describe Pomodoro::Formats::Scheduled::TaskGroup do
  describe '.new' do
    it "requires the header keyword argument" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it "succeeds when the header is provided" do
      task_group = described_class.new(header: 'Tomorrow')
      expect(task_group.header).to eql('Tomorrow')
      expect(task_group.tasks).to be_empty
    end
  end

  subject do
    described_class.new(header: 'Tomorrow', tasks: ['Buy milk.'])
  end

  describe '#<<' do
    it "adds a task into the group" do
      expect { subject << 'Task 1.' }.to change { subject.tasks.length }.by(1)
    end

    it "does not add the same task twice" do
      expect { subject << 'Buy milk.' }.not_to change { subject.tasks.length }
    end
  end

  describe '#delete' do
    it "removes a task group from the list" do
      expect { subject.delete('Buy milk.') }.to change { subject.tasks.length }.by(-1)
    end
  end

  describe '#to_s' do
    context "with tasks" do
      it "returns a valid scheduled task list formatted string" do
        expect(subject.to_s).to eql("Tomorrow\n- Buy milk.\n")
      end
    end

    context "without any tasks" do
      subject do
        described_class.new(header: 'Tomorrow')
      end

      it "returns a valid scheduled task list formatted string" do
        expect(subject.to_s).to eql("Tomorrow\n")
      end
    end
  end
end
