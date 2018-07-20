require "spec_helper"

RSpec.describe Arctic::Vendor::API do
  let(:instance) { described_class.new }
  subject { instance }

  before do
    ENV['ARCTIC_CORE_API_TOKEN'] = 'Hello'
    ENV['VENDOR_ID'] = 'Bob'
  end

  describe '#connection' do
    subject { instance.connection }
    it { is_expected.to be_a Faraday::Connection }
  end

  describe '#list_shops' do
    let(:shops) do
      [
        { id: 'shop1' },
        { id: 'shop2' },
      ].as_json
    end

    it 'calls the right API endpoint' do
      response = double body: shops.to_json, status: 200
      expect(instance.connection).to receive(:get)
        .with("shops")
        .and_return response
      expect(instance.list_shops).to eql shops
    end
  end

  describe '#send_products' do
    let(:products) do
      5.times.collect do |i|
        {
          id: "shop#{i}",
        }
      end.as_json
    end

    it 'calls the right API endpoint' do
      response = double body: '', status: 200
      expect(instance.connection).to receive(:post)
        .with("shops/shop1/products")
        .exactly(5).times
        .and_return response
      instance.send_products('shop1', products)
    end
  end

  describe '#list_products' do
    let(:products) do
      [
        {
          sku: 'product1',
          master_sku: nil,
          color: :black,
        },
        {
          sku: 'product2',
          master_sku: 'product1',
          color: :black,
        },
      ].as_json
    end

    it 'calls the right API endpoint' do
      response = double body: products.to_json, status: 200, headers: {}
      expect(instance.connection).to receive(:get)
        .at_least(:once)
        .with("shops/shop1/products")
        .and_return response

      instance.list_products('shop1') do |products|
        product = products.first
        expect(product).to be_a Hash
        expect(product.fetch('sku')).to eql('product1')
        expect(product.fetch('color')).to eql('black')
      end
    end
  end

  describe '#update_product' do
    it 'calls the right API endpoint' do
      response = double body: '', status: 200
      expect(instance.connection).to receive(:patch)
        .with("shops/shop1/products/abcdef123")
        .and_return response
      instance.update_product('shop1', 'abcdef123')
    end
  end
end
