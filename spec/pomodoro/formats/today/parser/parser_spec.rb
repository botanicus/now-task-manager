require 'pomodoro/formats/today'

class Parslet::Slice
  def eql?(slice_or_string)
    self.to_s == slice_or_string.to_s
  end
end

# Important building rules of the parser are specified in the rules_spec.rb.
describe Pomodoro::Formats::Today::Parser do
  describe "The most basic syntax" do
    let(:syntax_file) do
      File.read('spec/data/formats/today/1_basic.today')
    end

    it "allows empty files" do
      pending
      expect(subject.parse('')).to eql('')
      expect(subject.parse("\n")).to eql('')
      # TODO:
      # expect(subject.parse("\n \n \n ")).to eql(build_tree)
    end

    it "parses one time frame with no tasks" do
      pending
      tree = subject.parse("Time frame 1 (9:00 – 12:00)\n")
      expect(tree).to eql([{
        time_frame: {
          header: "Time frame 1 ",
          start_time: {hour: '9:00'},
          end_time:   {hour: '12:00'},
          task_list: []
        }
      }])
    end

    it "parses one time frame with one task" do
      pending
      tree = subject.parse("Time frame 1 (9:00 – 12:00)\n- Do something.")
      expect(tree).to eql([{
        time_frame: {
          header: "Time frame 1 ",
          start_time: {hour: '9:00'},
          end_time:   {hour: '12:00'},
          task_list: [
            task: [{indent: '-'}, {body: "Do something."}]
          ]
        }
      }])
    end

    it "parses one time frame with multiple task" do
      pending
      tree = subject.parse("Time frame 1 (9:00 – 12:00)\n- Do something.\n- Do something else.\n- Go to sleep.")
      expect(tree).to eql([{
        time_frame: {
          header: "Time frame 1 ",
          start_time: {hour: '9:00'},
          end_time:   {hour: '12:00'},
          task_list: [
            {task: [{indent: '-'}, {body: "Do something."}]},
            {task: [{indent: '-'}, {body: "Do something else."}]},
            {task: [{indent: '-'}, {body: "Go to sleep."}]}
          ]
        }
      }])
    end

    it "parses multiple time frames" do
      pending
      tree = subject.parse(syntax_file)
      expect(tree).to eql([{
        time_frame: {
          header: "Time frame 1 ",
          start_time: {hour: '9:00'},
          end_time:   {hour: '12:00'},
          task_list: [
            {task: [{indent: '✔'}, {body: "Task 1."}]},
            {task: [{indent: '✔'}, {body: "Coffee. "}, {tag: 'break'}]},
            {task: [{indent: '✘'}, {body: "Task 2."}, {tag: 'a'}, {tag: 'b'}, {tag: 'c'}]},
            {task: [{indent: '-'}, {body: "Task 3."}]},
          ]
        },
        time_frame: {
          header: "Lunch break ",
          start_time: {hour: '12:00'},
          end_time:   {hour: '13:00'},
        }
      }])
    end
  end
end
