require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Plan do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:config) do
    OpenStruct.new(data_root_path: "/")
  end

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  context "year" do
    let(:args) { ['year'] }

    it do
      run(subject)
    end
  end
end
