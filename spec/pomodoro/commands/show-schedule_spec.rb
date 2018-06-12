# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::ShowSchedule do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:args) { Array.new }

  let(:config) do
    OpenStruct.new(
      schedule_path: 'spec/data/schedules.rb',
      routine_path:  'spec/data/base.rb')
  end

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)

  context "with no argument" do
    it "prints out today's schedule" do
      # TODO: More schedules, so we can test which day is actually being selected.
      run(subject)

      expect(subject.sequence[0][:stdout]).to be_kind_of(Pomodoro::Formats::Today::TimeFrame)
      expect(subject.sequence[0][:stdout].name).to eql('Morning')

      expect(subject.sequence[1][:stdout]).to be_kind_of(Pomodoro::Formats::Today::TimeFrame)
      expect(subject.sequence[1][:stdout].name).to eql('Afternoon')

      expect(subject.sequence[2]).to eql(exit: 0)
    end
  end

  context "with a day name" do
    let(:args) { ['Saturday'] }

    # TODO
  end

  context "with a date increment" do
    let(:args) { ['+1'] }

    # TODO
  end

  context "with a schedule name" do
    let(:args) { ['holidays'] }

    # TODO
  end
end
