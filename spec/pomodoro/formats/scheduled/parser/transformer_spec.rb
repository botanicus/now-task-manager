require 'pomodoro/formats/scheduled'

describe Pomodoro::Formats::Scheduled::Transformer do
  let(:tree) do # Copied from the parser_spec.rb.
    [
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
    ]
  end

  describe '#apply' do
    it do
      ast = subject.apply(tree)
      expect(ast.length).to be(2)

      expect(ast[0].name).to eql('Tomorrow')
      expect(ast[0].tasks).to eql(["Buy shoes #errands", "[9:20] Call Tom."])

      expect(ast[1].name).to eql('Prague')
      expect(ast[1].tasks).to eql(['Task 1.'])
    end
  end
end
