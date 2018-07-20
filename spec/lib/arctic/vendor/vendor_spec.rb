require "spec_helper"

RSpec.describe Arctic::Vendor do
  before do
    ENV['ARCTIC_CORE_API_TOKEN'] = 'hello'
    ENV['VENDOR_ID'] = 'Bob'
  end

  let(:shop1) do
    {
      id: 'ghijkl456',
      type: 'collection',
    }.as_json
  end

  let(:shop2) do
    {
      id: 'mnopqr789',
      type: 'dispersal',
    }.as_json
  end

  let(:prod1) do
    {
      sku: 'product-1',
      color: 'black',
    }.as_json
  end

  before do
    allow(described_class.api).to receive(:list_shops).at_least(:once).and_return \
      dispersal: [shop2],
      collection: [shop1]
  end

  describe 'MAX_THREADS' do
    subject { Arctic::Vendor::MAX_THREADS }
    it { is_expected.to eql 4 }
  end

  describe '.threaded' do
    it 'runs the yielded block multi-threaded' do
      expect(Arctic.logger).to receive(:fatal).exactly(4).times
      described_class.threaded (1..4).to_a do |i|
        Arctic.logger.fatal i
      end
    end
  end

  describe '.each_shop' do
    it 'returns the filtered shops' do
      expect(Arctic.logger).to receive(:fatal).exactly(:once).with(shop1)
      described_class.each_shop do |shop|
        Arctic.logger.fatal shop
      end

      expect(Arctic.logger).to receive(:fatal).exactly(:once).with(shop2)
      described_class.each_shop(:dispersal) do |shop|
        Arctic.logger.fatal shop
      end
    end
  end

  describe '.api' do
    subject { described_class.api }
    it { is_expected.to be_a Arctic::Vendor::API }
  end

  describe '.time' do
    subject { described_class.time { sleep 1 } }

    it 'times the block' do
      expect(subject).to be_within(0.01).of(1.0)
    end

    it { is_expected.to be_a Float }
  end

  describe '.collect_products' do
    it 'yields the shop to the caller' do
      expect(described_class.api).to receive(:send_products).with(shop1['id'], [prod1]).and_return [prod1]
      described_class.collect_products do |shop|
        [prod1]
      end
    end
  end

  describe '.distribute_products' do
    it 'yields the shop to the caller' do
      expect(described_class.api).to receive(:list_products).with(shop2['id'], { batch_size: 100 }).and_yield [prod1]
      expect(described_class.api).to receive(:update_product).with(shop2['id'], prod1.fetch('sku'), { dispersed_at: Time.now.to_s(:db) })
      expect(Arctic.logger).to receive(:fatal).with(shop2)
      expect(Arctic.logger).to receive(:fatal).with([prod1])
      described_class.distribute_products do |shop, products|
        Arctic.logger.fatal shop
        Arctic.logger.fatal products
      end
    end

    context 'setting batch size' do
      it 'yields the shop to the caller' do
        expect(described_class.api).to receive(:list_products).with(shop2['id'], { batch_size: 10_000 }).and_yield [prod1]
        expect(described_class.api).to receive(:update_product).with(shop2['id'], prod1.fetch('sku'), { dispersed_at: Time.now.to_s(:db) })
        expect(Arctic.logger).to receive(:fatal).with(shop2)
        expect(Arctic.logger).to receive(:fatal).with([prod1])
        described_class.distribute_products(batch_size: 10_000) do |shop, products|
          Arctic.logger.fatal shop
          Arctic.logger.fatal products
        end
      end
    end
  end
end
