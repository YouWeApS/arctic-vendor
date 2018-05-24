require "spec_helper"

RSpec.describe Arctic::Vendor::API do
  let(:instance) { described_class.new }
  subject { instance }

  before { ENV['ARCTIC_CORE_API_TOKEN'] = 'Hello' }

  describe '#connection' do
    subject { instance.connection }
    it { is_expected.to be_a Faraday::Connection }
  end

  describe '#list_accounts' do
    let(:accounts) do
      [
        { id: 'account1' },
        { id: 'account2' },
      ].as_json
    end

    it 'calls the right API endpoint' do
      response = double body: accounts.to_json, status: 200
      expect(instance.connection).to receive(:get)
        .with('accounts')
        .and_return response
      expect(instance.list_accounts).to eql accounts
    end
  end

  describe '#show_account' do
    let(:account) { { id: 'account1' }.as_json }

    it 'calls the right API endpoint' do
      response = double body: account.to_json, status: 200
      expect(instance.connection).to receive(:get)
        .with("accounts/account1")
        .and_return response
      expect(instance.show_account('account1')).to eql account
    end
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
        .with("accounts/account1/shops")
        .and_return response
      expect(instance.list_shops('account1')).to eql shops
    end
  end

  describe '#send_products' do
    let(:products) do
      1001.times.collect do |i|
        {
          id: "shop#{i}",
        }
      end.as_json
    end

    it 'calls the right API endpoint' do
      response = double body: '', status: 202
      expect(instance.connection).to receive(:post)
        .with("accounts/account1/shops/shop1/products")
        .exactly(2).times
        .and_return response
      expect(instance.send_products('account1', 'shop1', products)).to eql products
    end
  end

  describe '#list_products' do
    let(:products) do
      [
        { id: 'product1' },
        { id: 'product2' },
      ].as_json
    end

    it 'calls the right API endpoint' do
      response = double body: products.to_json, status: 200
      expect(instance.connection).to receive(:get)
        .with("accounts/account1/shops/shop1/products")
        .and_return response
      expect(instance.list_products('account1', 'shop1')).to eql products
    end
  end
end
