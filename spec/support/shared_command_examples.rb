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
      run(subject)
      expect(subject.sequence[0]).to eql(abort: "<red>#{message}</red>")
    end
  end
end

RSpec.shared_examples(:requires_today_task_file) do
  context "without today_path" do
    let(:config) do
      OpenStruct.new(today_path: 'non-existent.today')
    end

    it "fails" do
      run(subject)
      expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist.</red>\n  Run the <yellow>g</yellow> command first.")
    end
  end
end
