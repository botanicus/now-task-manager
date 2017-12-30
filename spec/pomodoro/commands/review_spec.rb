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
  # include_examples(:requires_today_task_file)

  context "with a valid config", :valid_command do
    let(:config) do
      OpenStruct.new(
        today_path: "spec/data/#{described_class}.#{rand(1000)}.today",
        data_root_path: 'root')
    end

    let(:data) { '' }

    it '...' do
      pending
      run(subject)
    end
  end
end
