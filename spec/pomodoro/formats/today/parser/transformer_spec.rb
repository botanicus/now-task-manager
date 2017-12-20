require 'spec_helper'
require 'pomodoro/formats/today'

describe Pomodoro::Formats::Today::Transformer do
  it do
    time_frames = subject.apply(
      [
        {
          time_frame: {
            name: {str: "Morning routine"},
            start_time: {hour: '7:50'},
            end_time: {hour: '9:20'},
            items: [
              {
                task: {
                  indent: {str: '-'},
                  body: {str: "Meditation."}
                }
              }
            ]
          }
        }
      ]
    )
    expect(time_frames.length).to eql(1)

    time_frame = time_frames[0]
    expect(time_frame.name).to eql("Morning routine")
    expect(time_frame.start_time).to eql(h('7:50'))
    expect(time_frame.end_time).to eql(h('9:20'))

    expect(time_frame.items.length).to be(1)
  end
end
