# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/formats/scheduled'

describe Pomodoro::Formats::Scheduled::Parser do
  describe 'rules' do
    describe 'header' do
      it "parses anything followed by a new line" do
        expect {
          subject.header.parse("Tomorrow\n")
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
      it "parses header followed by any number of tasks" do
        expect {
          subject.task_group.parse("Tomorrow\n- Buy shoes #errands\n- [9:20] Call Tom.\n")
        }.not_to raise_error
      end
    end

    describe 'start_time' do
      it "parses header followed by any number of tasks" do
        expect {
          subject.start_time.parse('[9:20]')
        }.not_to raise_error
      end
    end

    describe 'time_frame' do
      it "does not parse start_time" do
        expect {
          subject.time_frame.parse('[9:20]')
        }.to raise_error
      end

      it "parses anything else between square brackets" do
        expect {
          subject.time_frame.parse('[Admin]')
        }.not_to raise_error
      end
    end
  end

  describe '#parse' do
    it "parses an empty file" do
      expect { subject.parse('') }.not_to raise_error
    end

    let(:task_group_1) do
      "Tomorrow\n- Buy shoes. #errands\n- [9:20] Call Tom.\n"
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
            header: {str: 'Tomorrow'},
            tasks: [
              {
                task: {
                  body: {str: "Buy shoes. "},
                  tags: [
                    {tag: {str: 'errands'}}
                  ]
                }
              }, {
                task: {
                  start_time: {hour: '9:20'},
                  body: {str: "Call Tom."},
                  tags: []
                }
              }
            ]
          }
        }, {
          task_group: {
            header: {str: 'Prague'},
            tasks: [
              {
                task: {
                  body: {str: "Task 1."},
                  tags: []
                }
              }
            ]
          }
        }
      ])
    end
  end
end
