require 'pomodoro/formats/scheduled'
require 'spec_helper'

describe Pomodoro::Formats::Scheduled::Parser do
  describe 'rules' do
    describe 'task_group_header' do
      it "parses anything followed by a new line" do
        expect {
          subject.task_group_header.parse("Tomorrow\n")
        }.not_to raise_error
      end
    end

    describe 'task' do
      it "parses anything that starts with a dash" do
        expect {
          subject.task.parse("- [9:20] Buy shoes #errands\n")
        }.not_to raise_error
      end
    end

    describe 'task_group' do
      it "parses task_group_header followed by any number of tasks" do
        expect {
          subject.task_group.parse("Tomorrow\n- Buy shoes #errands\n- [9:20] Call Tom.\n")
        }.not_to raise_error
      end
    end
  end

  describe '#parse' do
    it "parses an empty file" do
      expect { subject.parse('') }.not_to raise_error
    end

    let(:task_group_1) do
      "Tomorrow\n- Buy shoes #errands\n- [9:20] Call Tom.\n"
    end

    let(:task_group_2) do
      "Prague\n- Task 1.\n"
    end

    let(:task_groups) do
      [task_group_1, task_group_2].join("\n")
    end

    it "parses one task group" do
      expect { subject.parse(task_group_1) }.not_to raise_error
    end

    it "parses multiple task groups" do
      expect { subject.parse(task_groups) }.not_to raise_error
    end

    it "returns a tree" do
      tree = subject.parse(task_groups)
      expect(tree).to eql([
        {
          task_group: {
            task_group_header: 'Tomorrow',
            task_list: [
              {task: "Buy shoes #errands"},
              {task: "[9:20] Call Tom."}
            ]
          }
        }, {
          task_group: {
            task_group_header: 'Prague',
            task_list: [
              {task: "Task 1."}
            ]
          }
        }
      ])
    end
  end
end
