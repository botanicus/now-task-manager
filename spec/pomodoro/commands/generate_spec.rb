require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Generate do
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)

  context "with valid config" do
    let(:config) do
      Pomodoro::Config.new('spec/data/now-task-manager.yml')
    end

    it do
      # require 'pry'; binding.pry ###
      # run(subject)
    end
  end
end
