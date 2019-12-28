require "spec_helper"

RSpec.describe Arctic::Vendor::Dispersal::API do
  let(:instance) do
    described_class.new \
      vendor_id: vendor_id,
      vendor_token: vendor_token
  end

  let(:vendor_id) { 'id' }

  let(:vendor_token) { 'token' }

  let(:shop_id) { 1 }

  let(:request_options) do
    {
      headers: {
        'Accept'=>'application/json',
        'Authorization'=>'Basic aWQ6dG9rZW4=',
        'Content-Type'=>'application/json',
        'Expect' => '',
        'User-Agent'=>'Arctic-Vendor v1.0'
      }
    }
  end

  subject { instance }

  it { is_expected.to be_a Arctic::Vendor::API }

  describe '#list_products' do
    let(:products) { [1, 2, 3, 4, 5] }

    let(:response) do
      {
        status: 200,
        body: products,
      }
    end

    before do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/products?with_state_update=true")
        .with(**request_options)
        .to_return(response)
    end

    context 'no block given' do
      it 'returns all products across all pages' do
        expect(instance.list_products(shop_id, 5)).to match_array (1..5).to_a
      end
    end

    context 'block given' do
      it 'returns yields each of the product sets' do
        expect { |b| instance.list_products(shop_id, 5, &b) }.to \
          yield_successive_args(products)
      end
    end

    xit 'accepts additional params' do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/products?a=b&page=1")
        .with(**request_options)
        .to_return(response2)
      instance.list_products(shop_id, 1_000, page: 1, a: :b)
    end
  end

  describe '#report_error' do
    it 'calls the right endpoint' do
      request_options[:body] = {
        message: 'Some error',
        details: 'Error details',
        raw_data: {
          some: :data,
        },
      }.to_json

      stub_request(:post, "http://localhost:5000/v1/vendors/shops/1/products/prod1/errors")
        .with(**request_options)

      instance.report_error(shop_id, 'prod1', {
        message: 'Some error',
        details: 'Error details',
        raw_data: { some: :data },
      })
    end
  end

  describe '#collect_orders' do
    it 'calls the right endpoint' do
      request_options[:body] = {
        id: 'AZ1',
        status: :processing,
      }.to_json

      stub_request(:post, "http://localhost:5000/v1/vendors/shops/1/orders")
        .with(**request_options)
        .to_return(status: 201)

      instance.collect_order(shop_id, {
        id: 'AZ1',
        status: :processing,
      })
    end
  end

  describe '#collect_invoice' do
    it 'calls the right endpoint' do
      data = {
        invoice_id: 'I1',
        order_lines: [1, 2, 3],
        amount: 12.34,
        currency: 'dkk',
        status: 'awaiting_payment',
      }

      request_options[:body] = data.to_json

      stub_request(:post, "http://localhost:5000/v1/vendors/shops/1/orders/2/invoices")
        .with(**request_options)
        .to_return(status: 201)

      instance.collect_invoice(1, 2, data)
    end
  end

  describe '#collect_order_line' do
    it 'calls the right endpoint' do
      data = {
        line_id: 1,
        status: 'pending',
        product_id: 'abcdef123',
        quantity: 3,
        track_and_trace_reference: '2:1234',
      }

      request_options[:body] = data.to_json

      stub_request(:post, "http://localhost:5000/v1/vendors/shops/1/orders/2/order_lines")
        .with(**request_options)
        .to_return(status: 201)

      instance.collect_order_line(1, 2, data)
    end
  end

  describe '#last_synced_at' do
    let(:time) { 1.minute.ago.httpdate }

    it 'calls the right endpoint for orders routine' do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/orders/last_synced_at")
        .to_return(body: { last_synced_at: time }.to_json)
      expect(instance.last_synced_at(1, :orders)).to eql time
    end

    it 'calls the right endpoint for products routine' do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/products/last_synced_at")
        .to_return(body: { last_synced_at: time }.to_json)
      expect(instance.last_synced_at(1, :products)).to eql time
    end
  end

  describe '#synced' do
    it 'calls the right endpoint' do
      stub_request(:patch, "http://localhost:5000/v1/vendors/shops/1/products_synced")
        .with(**request_options)

      instance.synced(shop_id, :products)
    end

    context 'for orders' do
      it 'calls the right endpoint' do
        stub_request(:patch, "http://localhost:5000/v1/vendors/shops/1/orders_synced")
          .with(**request_options)

        instance.synced(shop_id, :orders)
      end
    end
  end
end
