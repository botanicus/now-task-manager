RSpec.shared_examples(:has_help) do
  describe '.help' do
    it "has it" do
      expect(described_class).to respond_to(:help)
      expect(described_class.help.length).not_to be(0)
    end
  end
end

RSpec.shared_examples(:missing_config) do
  context "without config" do
    let(:path) do
      'non-existent-now-task-manager.yml'
    end

    let(:config) do
      Pomodoro::Config.new(path)
    end

    let(:message) do
      I18n.t('errors.config.missing_file', path: path)
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>#{message}</red>")
    end
  end
end
