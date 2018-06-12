require 'spec_helper'
require 'pomodoro/formats/scheduled/task'

describe Pomodoro::Formats::Scheduled::Task do
  describe '.new' do
    it "requires body" do
      expect { described_class.new }.to raise_error(ArgumentError, /missing keyword: body/)
    end

    it "requires non-empty body" do
      expect { described_class.new(body: '') }.to raise_error(ArgumentError, /cannot be empty/)
    end

    it "accepts start_time" do
      task = described_class.new(body: "Task 1.", start_time: h('0:10'))
      expect(task.start_time).to eql(h('0:10'))
    end

    it "accepts time_frame" do
      task = described_class.new(body: "Task 1.", time_frame: "Admin")
      expect(task.time_frame).to eql("Admin")
    end

    it "fails if tags are not symbols" do
      expect { described_class.new(body: "Task 1.", tags: [Object.new]) }.to raise_error(
        ArgumentError, /Tags are supposed to be an array of symbols./)
    end

    it "accepts tags that are symbols" do
      task = described_class.new(body: "Task 1.", tags: [:spanish, :'3pt'])
      expect(task.tags).to eql([:spanish, :'3pt'])
    end
  end

  describe '#to_s' do
    it "formats the body" do
      task = described_class.new(body: "Task 1.")
      expect(task.to_s).to eql("- Task 1.")
    end

    it "formats the body and start_time" do
      task = described_class.new(body: "Task 1.", start_time: h('0:25'))
      expect(task.to_s).to eql("- [0:25] Task 1.")
    end

    it "formats the body and time_frame" do
      task = described_class.new(body: "Task 1.", time_frame: "Admin")
      expect(task.to_s).to eql("- [Admin] Task 1.")
    end

    it "formats the body, start_time and time_frame" do
      task = described_class.new(body: "Task 1.", start_time: h('0:25'), time_frame: "Admin")
      expect(task.to_s).to eql("- [Admin] [0:25] Task 1.")
    end

    it "formats the body, start_time, time_frame and tags" do
      task = described_class.new(body: "Task 1.", start_time: h('0:25'), time_frame: "Admin", tags: [:important, :'3pt'])
      expect(task.to_s).to eql("- [Admin] [0:25] Task 1. #important #3pt")
    end
  end
end
