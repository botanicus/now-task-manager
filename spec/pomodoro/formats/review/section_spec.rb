# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/formats/review'

describe Pomodoro::Formats::Review::Section do
  subject do
    described_class.new(header: 'Custom', raw_data: '')
  end

  it do
    expect(subject.header).to eql('Custom')
    expect(subject.raw_data).to be_empty
    expect(subject.data).to be_empty
  end
end
