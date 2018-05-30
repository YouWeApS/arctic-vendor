require "spec_helper"

RSpec.describe Arctic::Vendor::Product do
  let(:instance) { described_class.new account_id, shop_id, data, api }

  let(:account_id) { 'account1' }
  let(:shop_id) { 'shop1' }
  let(:api) { double }

  let(:data) do
    {
      id: 'product1',
      characteristics: {
        color: :black,
      },
      master: 'product2',
      state: :deleted,
    }.as_json
  end

  describe '#id' do
    subject { instance.id }
    it { is_expected.to eql 'product1' }
  end

  describe '#characteristics' do
    subject { instance.characteristics }
    it { is_expected.to be_a Hashie::Mash } # allow Product.characteristics.color
    it { is_expected.to eql({ color: :black }.as_json) }
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
