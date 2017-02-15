require 'pomodoro/task'

describe Pomodoro::Task do
  describe '.parse' do
    it 'parses a simple line' do
      task = described_class.parse('- Do your homework.')
      expect(task.text).to eql('Do your homework.')
      expect(task.duration).to be(described_class::DEFAULT_DURATION)
      expect(task.tags).to be_empty
    end

    it 'parses a line with tags' do
      task = described_class.parse('- Do your homework. #online #boring')
      expect(task.text).to eql('Do your homework.')
      expect(task.duration).to be(described_class::DEFAULT_DURATION)
      expect(task.tags).to eql([:online, :boring])
    end

    it 'parses a line with duration' do
      task = described_class.parse('- [25] Do your homework.')
      expect(task.text).to eql('Do your homework.')
      expect(task.duration).to be(25)
      expect(task.tags).to be_empty
    end

    it 'parses a line with tags and duration' do
      task = described_class.parse('- [25] Do your homework. #online #boring')
      expect(task.text).to eql('Do your homework.')
      expect(task.duration).to be(25)
      expect(task.tags).to eql([:online, :boring])
    end
  end

  describe '#to_s' do
    it 'prints the same output as was the input for a simple line' do
      input = '- Do your homework.'
      task = described_class.parse(input)
      expect(task.to_s).to eql(input)
    end

    it 'prints the same output as was the input for a line with tags' do
      input = '- Do your homework. #online #boring'
      task = described_class.parse(input)
      expect(task.to_s).to eql(input)
    end

    it 'prints the same output as was the input for a line with duration' do
      input = '- [25] Do your homework.'
      task = described_class.parse(input)
      expect(task.to_s).to eql(input)
    end

    it 'prints the same output as was the input for a line with tags and duration' do
      input = '- [25] Do your homework. #online #boring'
      task = described_class.parse(input)
      expect(task.to_s).to eql(input)
    end
  end
end
