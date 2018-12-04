require "spec_helper"

RSpec.shared_context :last_synced_at do |time, routine = :products|
  before do
    stub_request(:get, "http://localhost:5000/v1/vendors/shops/#{shop_id}/orders/last_synced_at")
      .to_return \
        body: { last_synced_at: DateTime.parse(time).try(:httpdate) }.to_json,
        status: 200
  end
end

RSpec.describe Arctic::Vendor::Collection::API do
  let(:instance) do
    described_class.new \
      vendor_id: 'collection-id',
      vendor_token: 'collection-token'
  end

  describe '#collect_orders' do
    subject { instance.collect_orders(shop_id) }

    let(:shop_id) { 1 }

    let(:order1) do
      {
        id: 'Order1',
      }
    end

    let(:order2) do
      {
        id: 'Order2',
      }
    end

    let(:orders) { [order1, order2] }

    include_context :last_synced_at, '2018-11-11 10:00:00', :orders

    it 'collects the orders from the Core API' do
      date = CGI.escape DateTime.parse('2018-11-11 10:00:00').httpdate

      stub_request(:get, "http://localhost:5000/v1/vendors/shops/#{shop_id}/orders?since=#{date}")
        .to_return \
          body: orders.to_json,
          status: 200

      expect(subject).to eql orders.as_json
    end
  end
end
