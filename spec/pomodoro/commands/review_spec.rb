# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Review do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)

  let(:config) do
    OpenStruct.new(data_root_path: 'root')
  end

  around(:each) do |example|
    Timecop.freeze(Date.parse('2018/5/3')) do
      example.run
    end
  end

  context "day" do
    # TODO: in review.rb we're using config.today_path(date), whereas shared_examples use openstruct.
    # include_examples(:requires_today_task_file)

    context "with a valid config", :valid_command do
      let(:config) do
        OpenStruct.new(
          today_path: "spec/data/#{described_class}.#{rand(1000)}.today",
          data_root_path: 'root')
      end

      let(:data) { '' }

      it "opens the day review file in Vim" do
        pending "config is just an openstruct"
        run(subject)
      end
    end
  end

  context "week" do
    let(:args) { ['week'] }

    it "opens the week review file in Vim" do
      run(subject)

      expect(subject.sequence[0]).to eql(command: "vim root/2018/features/weeks/18_review.md")
      expect(subject.sequence[1]).to eql(exit: 0)
    end
  end

  context "month" do
    let(:args) { ['month'] }

    it "opens the month review file in Vim" do
      run(subject)

      expect(subject.sequence[0]).to eql(command: "vim root/2018/features/months/May_review.md")
      expect(subject.sequence[1]).to eql(exit: 0)
    end
  end

  context "quarter" do
    let(:args) { ['quarter'] }

    it "opens the quarter review file in Vim" do
      run(subject)

      expect(subject.sequence[0]).to eql(command: "vim root/2018/features/Q2_review.md")
      expect(subject.sequence[1]).to eql(exit: 0)
    end
  end

  context "year" do
    let(:args) { ['year'] }

    it "opens the year review file in Vim" do
      run(subject)

      expect(subject.sequence[0]).to eql(command: "vim root/2018/features/2018_review.md")
      expect(subject.sequence[1]).to eql(exit: 0)
    end
  end
end
