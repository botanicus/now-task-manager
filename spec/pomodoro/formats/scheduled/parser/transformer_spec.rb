# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/formats/scheduled'

describe Pomodoro::Formats::Scheduled::Transformer do
  let(:tree) do # Copied from the parser_spec.rb.
    [
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
              },
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
    ]
  end

  describe '#apply' do
    it do
      ast = subject.apply(tree)
      expect(ast.length).to be(2)

      expect(ast[0].header).to eql('Tomorrow')

      expect(ast[0].tasks.length).to be(2)
      tasks = ast[0].tasks

      expect(tasks[0].body).to eql("Buy shoes.")
      expect(tasks[0].tags).to eql([:errands])
      expect(tasks[0].start_time).to be_nil
      expect(tasks[0].time_frame).to be_nil

      expect(tasks[1].body).to eql("Call Tom.")
      expect(tasks[1].tags).to be_empty
      expect(tasks[1].start_time).to eql(h('9:20'))
      expect(tasks[1].time_frame).to be_nil

      expect(ast[1].header).to eql('Prague')

      expect(ast[1].tasks.length).to be(1)
      task = ast[1].tasks[0]
      expect(task.body).to eql("Task 1.")
      expect(task.tags).to be_empty
      expect(task.start_time).to be_nil
      expect(task.time_frame).to be_nil
    end
  end
end
