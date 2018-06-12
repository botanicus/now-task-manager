# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/formats/scheduled'

describe Pomodoro::Formats::Scheduled do
  describe '.parse' do
    it "parses a task list and returns a TaskList instance" do
      task_list = described_class.parse <<-EOF.gsub(/^\s*/, '')
        Tomorrow
        - Buy milk. #errands
        - [9:20] Call with Mike.

        Prague
        - Pick up my shoes. #errands
      EOF

      expect(task_list).to be_kind_of(described_class::TaskList)
    end

    it "returns an empty task list object for an empty task list" do
      expect(described_class.parse('')).to be_kind_of(described_class::TaskList)
    end
  end
end
