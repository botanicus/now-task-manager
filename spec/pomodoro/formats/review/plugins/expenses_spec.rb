require 'spec_helper'
require 'pomodoro/formats/review'

describe Pomodoro::Formats::Review::Plugins::Expenses::Parser do
  describe '.payment_method' do
    it do
      expect {
        subject.payment_method.parse('[FIO VISA]')
      }.not_to raise_error
    end
  end

  describe '.currency' do
    it do
      expect {
        subject.currency.parse('PLN')
      }.not_to raise_error
    end
  end

  describe '.amount_and_tip' do
    it do
      expect {
        subject.amount_and_tip.parse('10')
      }.not_to raise_error
    end

    it do
      expect {
        subject.amount_and_tip.parse('10.25')
      }.not_to raise_error
    end

    it do
      expect {
        subject.amount_and_tip.parse('10 + 1')
      }.not_to raise_error
    end

    it do
      expect {
        subject.amount_and_tip.parse('9.25 + 1.25')
      }.not_to raise_error
    end
  end

  describe '.expense' do
    it do
      expect {
        subject.expense.parse("PLN 10 Lunch.\n")
      }.not_to raise_error
    end

    it do
      expect {
        subject.expense.parse("PLN 10 + 2 Lunch.\n  Line.\n")
      }.not_to raise_error
    end
  end

  describe '.parse' do
    let(:data) do
      <<-EOF.gsub(/^ {8}/, '')
        [FIO VISA] CZK 120.25 + 10 Lunch.
          Note.
        CZK 30 ABC.
        PLN 9.25 Piwo.
      EOF
    end

    it do
      expect { subject.parse(data) }.not_to raise_error
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

describe Pomodoro::Formats::Review::Plugins::Expenses do
  let(:data) do
    <<-EOF.gsub(/^ {6}/, '')
      [FIO VISA] CZK 120.25 + 10 Lunch.
        Note.
      CZK 30 ABC.
      PLN 9.25 Piwo.
    EOF
  end

  describe '.parse' do
    it do
      tree = described_class.parse(data)
      expect(tree).to be_kind_of(Pomodoro::Formats::Review::Plugins::Expenses::Expenses)
      expect(tree.length).to be(3)

      expect(tree[0].payment_method).to eql('FIO VISA')
      expect(tree[0].currency).to eql(:CZK)
      expect(tree[0].amount).to eql(120.25)
      expect(tree[0].tip).to eql(10.0)
      expect(tree[0].description).to eql('Lunch.')
      expect(tree[0].notes).to eql(['Note.'])

      expect(tree[1].payment_method).to eql('cash')
      expect(tree[1].currency).to eql(:CZK)
      expect(tree[1].amount).to eql(30.0)
      expect(tree[1].description).to eql('ABC.')

      expect(tree[2].payment_method).to eql('cash')
      expect(tree[2].currency).to eql(:PLN)
      expect(tree[2].amount).to eql(9.25)
      expect(tree[2].description).to eql('Piwo.')
    end
  end
end

describe Pomodoro::Formats::Review::Plugins::Expenses::Expense do
  subject do
    described_class.new(amount: 120.0, currency: :CZK, description: 'Lunch.')
  end

  describe '#total' do
    context "with no tip" do
      it do
        expect(subject.total).to eql(subject.amount)
      end
    end

    context "with a tip" do
      subject do
        described_class.new(amount: 120.0, tip: 10.0, currency: :CZK, description: 'Lunch.')
      end

      it do
        expect(subject.total).to eql(130.0)
      end
    end
  end
end

describe Pomodoro::Formats::Review::Plugins::Expenses::Expenses do
  subject do
    described_class.new([
      Pomodoro::Formats::Review::Plugins::Expenses::Expense.new(
        amount: 120.0, tip: 10.25, currency: :CZK, description: 'Lunch.'
      ),
      Pomodoro::Formats::Review::Plugins::Expenses::Expense.new(
        amount: 30.0, currency: :CZK, description: 'ABC.'
      ),
      Pomodoro::Formats::Review::Plugins::Expenses::Expense.new(
        amount: 9.25, currency: :PLN, description: 'Piwo.'
      ),
    ])
  end

  describe '#totals' do
    it do
      expect(subject.totals).to eql({CZK: 160.25, PLN: 9.25})
    end
  end
end
