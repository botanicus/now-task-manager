require 'spec_helper'
require 'pomodoro/formats/review'

describe Pomodoro::Formats::Review::Plugins::Expenses::Parser do
  describe '.currency' do
    it do
      expect {
        subject.currency.parse('PLN')
      }.not_to raise_error
    end
  end

  describe '.amount' do
    it do
      expect {
        subject.amount.parse('10')
      }.not_to raise_error
    end

    it do
      expect {
        subject.amount.parse('10.25')
      }.not_to raise_error
    end
  end

  describe '.expense' do
    it do
      expect {
        subject.expense.parse("PLN 10 Lunch.\n")
      }.not_to raise_error
    end
  end
end

describe Pomodoro::Formats::Review::Section do
  context 'with no data' do
    subject do
      described_class.new(header: 'Expenses', raw_data: '')
    end

    it do
      expect(subject.data).to eql([])
    end
  end

  context 'with data' do
    subject do
      described_class.new(header: 'Expenses', raw_data: "PLN 10 Lunch.")
    end

    it do
      expect(subject.data.length).to be(1)
      expect(subject.data[0]).to be_kind_of(Pomodoro::Formats::Review::Plugins::Expenses::Expense)
    end
  end
end
