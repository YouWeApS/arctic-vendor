require "spec_helper"

RSpec.describe Arctic::Vendor::Product do
  let(:instance) { described_class.new account_id, shop_id, data, api }

  let(:account_id) { 'account1' }
  let(:shop_id) { 'shop1' }
  let(:api) { double }

  let(:data) do
    {
      sku: 'product1',
      characteristics: {
        color: :black,
      },
      master: 'product2',
      state: :deleted,
      images: [
        'https://google.com/1',
      ],
    }.as_json
  end

  describe '#sku' do
    subject { instance.sku }
    it { is_expected.to eql 'product1' }
  end

  describe '#characteristics' do
    subject { instance.characteristics }
    it { is_expected.to be_a Arctic::Vendor::Product::Characteristics }

    it 'provides dot-notation' do
      expect(instance.characteristics.color).to eql 'black'
      expect(instance.characteristics.ean).to be_nil
    end
  end

  describe '#images' do
    subject { instance.images }
    it { is_expected.to match_array ['https://google.com/1'] }
  end

  describe '#state' do
    subject { instance.state }
    it { is_expected.to eql('deleted') }
  end

  describe '#master' do
    subject { instance.master }
    it { is_expected.to eql('product2') }
  end
end
