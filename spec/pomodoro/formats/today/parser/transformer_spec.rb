require 'spec_helper'
require 'pomodoro/formats/today'

describe Pomodoro::Formats::Today::Transformer do
  it do
    pending
    time_frames = subject.apply(
      [
        {
          time_frame: {
            header: "Morning routine",
            start_time: {hour: '7:50'},
            end_time: {hour: '9:20'},
            task_list: [
              {
                task: [
                  {indent: '-'},
                  {body: "Meditation."}
                ]
              }
            ]
          }
        }
      ]
    )
    expect(time_frames.length).to eql(1)

    time_frame = time_frames[0]
    expect(time_frame.header).to eql("Morning routine")
    expect(time_frame.start_time).to eql(Hour.parse('7:50'))
    expect(time_frame.end_time).to eql(Hour.parse('9:20'))

    expect(time_frame.tasks.length).to be(1)
  end
end
