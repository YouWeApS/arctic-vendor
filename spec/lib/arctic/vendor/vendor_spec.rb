require "spec_helper"

RSpec.describe Arctic::Vendor do
  before { ENV['ARCTIC_CORE_API_TOKEN'] = 'hello' }

  let(:account1) do
    {
      id: 'abcdef123',
    }.as_json
  end

  let(:shop1) do
    {
      id: 'ghijkl456',
      type: 'source',
    }.as_json
  end

  let(:shop2) do
    {
      id: 'mnopqr789',
      type: 'target',
    }.as_json
  end

  let(:prod1) do
    {
      id: 'product-1',
      characteristics: {
        color: 'black',
      },
    }.as_json
  end

  before do
    allow(described_class.api).to receive(:list_accounts).exactly(2).times.and_return [account1]
    allow(described_class.api).to receive(:list_shops).exactly(2).times.and_return [shop1, shop2]
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
      described_class.each_shop(type: :target) do |shop|
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
      expect(described_class.api).to receive(:send_products).with(account1['id'], shop1['id'], [prod1]).and_return []
      expect(described_class.api).to receive(:synchronized).with(account1['id'], shop1['id'])
      described_class.collect_products do |shop|
        [prod1]
      end
    end
  end

  describe '.distribute_products' do
    it 'yields the shop to the caller' do
      expect(described_class.api).to receive(:list_products).with(account1['id'], shop2['id'], { per_page: 100 }).and_yield [prod1]
      expect(described_class.api).to receive(:synchronized).with(account1['id'], shop2['id'])
      expect(Arctic.logger).to receive(:fatal).with(shop2)
      expect(Arctic.logger).to receive(:fatal).with([prod1])
      described_class.distribute_products do |shop, products|
        Arctic.logger.fatal shop
        Arctic.logger.fatal products
      end
    end

    context 'setting batch size' do
      it 'yields the shop to the caller' do
        expect(described_class.api).to receive(:list_products).with(account1['id'], shop2['id'], { per_page: 10_000 }).and_yield [prod1]
        expect(described_class.api).to receive(:synchronized).with(account1['id'], shop2['id'])
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
