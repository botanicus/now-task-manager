# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/formats/today'

describe Pomodoro::Formats::Today::Task do
  let(:start_time) { h('10:00') }
  let(:end_time)   { h('12:00') }

  describe '.new' do
    it "allows start_time to be set" do
      task = described_class.new(
        body: "Buy milk.", status: :not_done, start_time: start_time)
      expect(task.start_time).to eql(start_time)
    end

    it "allows start_time and end_time to be set" do
      task = described_class.new(
        body: "Buy milk.", status: :done,
        start_time: start_time, end_time: end_time)

      expect(task.start_time).to eql(start_time)
      expect(task.end_time).to   eql(end_time)
    end

    it "does not allow only end_time to be set" do
      expect {
        described_class.new(body: "Buy milk.", status: :not_done, end_time: end_time)
      }.to raise_error(ArgumentError, /Setting end_time without start_time is invalid/)
    end

    it "does not allow start_time to be bigger to the end_time" do
      expect {
        described_class.new(body: "Buy milk.",
          status: :done, start_time: end_time, end_time: start_time)
      }.to raise_error(ArgumentError, /start_time has to be smaller than end_time/)
    end

    it "does not allow start_time to be same as the end_time" do
      expect {
        described_class.new(body: "Buy milk.",
          status: :not_done, start_time: start_time, end_time: start_time)
      }.to raise_error(ArgumentError, /start_time has to be smaller than end_time/)
    end

    it "allows duration to be set" do
      task = described_class.new(body: "Buy milk.", status: :not_done, duration: h('0:05'))
      expect(task.duration).to eql(h('0:05'))
    end

    it "does not allow duration to be anything but integer" do
      expect {
        described_class.new(body: "Buy milk.", status: :not_done, duration: 10)
      }.to raise_error(ArgumentError, /Duration has to be an Hour instance/)
    end

    it "does not allow duration to be smaller than 5 minutes" do
      expect {
        pending "Possibly won't be implemented."
        described_class.new(body: "Buy milk.", status: :not_done, duration: h('0:02'))
      }.to raise_error(ArgumentError, /Duration has between 5 and 90 minutes/)
    end

    it "does not allow duration to be bigger than 90 minutes" do
      expect {
        pending "Possibly won't be implemented."
        described_class.new(body: "Buy milk.", status: :not_done, duration: h('1:55'))
      }.to raise_error(ArgumentError, /Duration has between 5 and 90 minutes/)
    end

    it "allows status to be set" do
      task = described_class.new(body: "Buy milk.", status: :done)
      expect(task.status).to eql(:done)
    end

    it "does not allow unknown statuses" do
      expect {
        described_class.new(body: "Buy milk.", status: :error)
      }.to raise_error(ArgumentError, /Status has to be one of/)
    end

    it "does not allow unknown statuses" do
      expect {
        described_class.new(body: "Buy milk.", status: :unstarted, start_time: start_time, end_time: end_time)
      }.to raise_error(ArgumentError, /Status has to be one of/)
    end
  end
end
