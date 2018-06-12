# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Config do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  # TODO: refactor to use:
  # include_examples(:missing_config)

  context "without config" do
    let(:config) do
      Pomodoro::Config.new('non-existent-now-task-manager.yml')
    end

    let(:message) do
      I18n.t('errors.config.missing_file', path: 'non-existent-now-task-manager.yml')
    end

    # This doesn't work, because of the stubs.
    # Normally, p would do puts(object.inspect) and Config#inspect is where
    # the exception would occur. But since we're redefining Kernel#p, it never
    # gets there, so it looks like it prints the inspected config object
    # successfuly, but that's not true.
    it "fails" do
      pending "See the comment above."
      run(subject)
      expect(subject.sequence[0]).to eql(abort: "<red>#{message}</red>")
    end
  end

  context "with a valid config" do
    let(:config) do
      Pomodoro::Config.new('spec/data/now-task-manager.yml')
    end

    context "with no arguments" do
      it "prints out the whole config" do
        run(subject)
        expect(subject.sequence[0][:stdout]).to eql("<bold>Path:</bold> <bright_black>#{config.path}</bright_black>\n\n")
        expect(subject.sequence[1][:stdout]).to match(/data_root_path/)
        expect(subject.sequence[2]).to eql(exit: 0)
      end
    end

    context "with a key" do
      let(:args) { ['today_path'] }

      it "prints out its value" do
        run(subject)
        expect(subject.sequence[0][:stdout]).to match("/#{Date.today.strftime('%Y-%m-%d')}.today")
        expect(subject.sequence[1]).to eql(exit: 0)
      end
    end

    context "with a key and an argument" do
      let(:args) { ['today_path', '2015-01-31'] }

      it "prints out its value" do
        run(subject)
        expect(subject.sequence[0][:stdout]).to match("/2015-01-31.today")
        expect(subject.sequence[1]).to eql(exit: 0)
      end
    end
  end
end
