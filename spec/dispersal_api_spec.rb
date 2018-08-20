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
    let(:products1) { [1, 2, 3, 4, 5] }

    let(:response1) do
      {
        status: 200,
        body: products1,

        # We only _need_ headers in first response. API will supply them in
        # every response, however.
        headers: {
          'Total' => '11',
          'Per-Page' => '5',
        },
      }
    end

    let(:products2) { [6, 7, 8, 9, 10] }

    let(:response2) do
      {
        status: 200,
        body: products2,
      }
    end

    let(:products3) { [11] }

    let(:response3) do
      {
        status: 200,
        body: products3,
      }
    end

    before do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/products")
        .with(**request_options)
        .to_return(response1)

      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/products?page=2")
        .with(**request_options)
        .to_return(response2)

      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/products?page=3")
        .with(**request_options)
        .to_return(response3)
    end

    context 'no block given' do
      it 'returns all products across all pages' do
        expect(instance.list_products(shop_id)).to match_array (1..11).to_a
      end
    end

    context 'block given' do
      it 'returns yields each of the product sets' do
        expect { |b| instance.list_products(shop_id, &b) }.to \
          yield_successive_args(products1, products2, products3)
      end
    end

    it 'accepts additional params' do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/products?a=b&page=1")
        .with(**request_options)
        .to_return(response2)
      instance.list_products(shop_id, page: 1, a: :b)
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

      instance.collect_order(shop_id, {
        id: 'AZ1',
        status: :processing,
      })
    end
  end

  describe '#update_product_state' do
    it 'calls the right endpoint' do
      request_options[:body] = { state: 'inprogress' }.to_json

      stub_request(:patch, "http://localhost:5000/v1/vendors/shops/1/products/AZ1")
        .with(**request_options)

      instance.update_product_state(shop_id, 'AZ1', 'inprogress')
    end
  end

  describe '#completed_dispersal' do
    it 'calls the right endpoint' do
      stub_request(:patch, "http://localhost:5000/v1/vendors/shops/1")
        .with(**request_options)

      instance.completed_dispersal(shop_id)
    end
  end
end
