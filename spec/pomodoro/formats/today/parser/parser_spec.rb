require 'spec_helper'
require 'pomodoro/formats/today'

# Important building rules of the parser are specified in the rules_spec.rb.
describe Pomodoro::Formats::Today::Parser do
  describe "The most basic syntax" do
    let(:syntax_file) do
      File.read('spec/data/formats/today/1_basic.today')
    end

    it "allows empty files" do
      expect { subject.parse("") }.not_to raise_error
      expect { subject.parse("\n") }.not_to raise_error
    end

    it "parses a special day" do
      x = "@holidays\n"

      expect { subject.parse(x) }.not_to raise_error

      tree = subject.parse(x)
      expect(tree[:tags][0]).to eql(tag: :holidays)
    end

    it "parses one time frame with no tasks" do
      x = "Time frame 1 (9:00 – 12:00)\n"

      expect { subject.parse(x) }.not_to raise_error

      tree = subject.parse(x)
      expect(tree).to eql([{
        time_frame: {
          name: "Time frame 1 ",
          start_time: {hour: '9:00'},
          end_time:   {hour: '12:00'},
          tasks: []
        }
      }])
    end

    it "parses one time frame with one task" do
      x = "Time frame 1 (9:00 – 12:00)\n- Do something."

      expect { subject.parse(x) }.not_to raise_error

      tree = subject.parse(x)
      expect(tree).to eql([{
        time_frame: {
          name: "Time frame 1 ",
          start_time: {hour: '9:00'},
          end_time:   {hour: '12:00'},
          tasks: [
            task: [{indent: '-'}, {body: "Do something."}]
          ]
        }
      }])
    end

    it "parses one time frame with multiple task" do
      x = "Time frame 1 (9:00 – 12:00)\n- Do something.\n- Do something else.\n- Go to sleep."

      expect { subject.parse(x) }.not_to raise_error

      tree = subject.parse(x)
      expect(tree).to eql([{
        time_frame: {
          name: "Time frame 1 ",
          start_time: {hour: '9:00'},
          end_time:   {hour: '12:00'},
          tasks: [
            {task: [{indent: '-'}, {body: "Do something."}]},
            {task: [{indent: '-'}, {body: "Do something else."}]},
            {task: [{indent: '-'}, {body: "Go to sleep."}]}
          ]
        }
      }])
    end

    it "parses multiple time frames" do
      expect { subject.parse(syntax_file) }.not_to raise_error

      tree = subject.parse(syntax_file)

      expect(tree).to eql([
        {
          time_frame: {
            name: "Time frame 1 ",
            start_time: {hour: '9:00'},
            end_time:   {hour: '12:00'},
            tasks: [
              {task: [{indent: '✔'}, {body: "Task 1."}]},
              {task: [{indent: '✔'}, {body: "Coffee. "}, {tag: 'break'}]},
              {task: [{indent: '✘'}, {body: "Task 2. "}, {tag: 'a'}, {tag: 'b'}, {tag: 'c'}]},
              {task: [{indent: '-'}, {body: "Task 3."}]},
            ]
          }
        }, {
          time_frame: {
            name: "Lunch break ",
            start_time: {hour: '12:00'},
            end_time:   {hour: '14:00'},
            tasks: []
          }
        }
      ])
    end
  end
end
