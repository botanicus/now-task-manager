require 'pomodoro/exts/hour'

describe Hour do
  describe '#initialize' do
    it 'can be initialised with a mix of hours and minutes' do
      expect(described_class.new(0, 20).to_s).to eql('0:20')
      expect(described_class.new(2, 20).to_s).to eql('2:20')
      expect(described_class.new(2, 80).to_s).to eql('3:20')
    end
  end

  describe '#+' do
    it 'can add another instance of Hour' do
      expect(described_class.new(0, 20) + described_class.new(1, 25)).to eql(described_class.new(1, 45))
    end
  end
end
