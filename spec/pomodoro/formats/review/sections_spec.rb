# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/formats/review'

describe Pomodoro::Formats::Review::Sections do
  let(:section) do
    Pomodoro::Formats::Review::Section.new(header: 'Custom', raw_data: '')
  end

  subject do
    described_class.new([section])
  end

  it do
    expect(subject.custom).to be_kind_of(Pomodoro::Formats::Review::Section)
  end
end
