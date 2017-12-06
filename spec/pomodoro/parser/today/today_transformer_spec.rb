require 'pomodoro/parser/today_transformer'

describe Pomodoro::ObjectTransformer do
  it do
    ast = subject.apply(
      [
        {
          time_frame: {
            desc: "Morning routine",
            start_time: {hour: '7:50'},
            end_time: {hour: '9:20'},
            task_list: [
              {
                task: [
                  {indent: '-'},
                  {desc: "Meditation."}
                ]
              }
            ]
          }
        }
      ]
    )
    expect(ast).to eql({})
  end
end
