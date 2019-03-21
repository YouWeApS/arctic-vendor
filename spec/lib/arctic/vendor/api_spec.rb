require "spec_helper"

RSpec.describe Arctic::Vendor::API do
  let(:instance) do
    described_class.new \
      vendor_id: vendor_id,
      vendor_token: vendor_token
  end

  let(:vendor_id) { 'id' }

  let(:vendor_token) { 'token' }

  describe '#connection' do
    subject { instance.connection }

    it { is_expected.to be_a Faraday::Connection }

    it 'has the correct headers' do
      expect(subject.headers['Content-Type']).to eql 'application/json'
      expect(subject.headers['Accept']).to eql 'application/json'
      expect(subject.headers['Authorization']).to eql 'Basic aWQ6dG9rZW4='
      expect(subject.headers['User-Agent']).to eql 'Arctic-Vendor v1.0'
    end

    it 'reads the URL from the ENV by default' do
      expect(ENV).to receive(:fetch)
        .with('ARCTIC_CORE_API_URL')
        .and_return 'https://google.com'
      expect(subject.url_prefix.to_s).to eql 'https://google.com/' # see ENV at the
    end
  end

  describe '#update_order' do
    it 'calls the right endpoint' do
      stub_request(:patch, "http://localhost:5000/v1/vendors/shops/1/orders/2")
        .with(
            body: "{\"id\":2,\"a\":\"b\"}",
            headers: {
            'Accept'=>'application/json',
            'Authorization'=>'Basic aWQ6dG9rZW4=',
            'Content-Type'=>'application/json',
            'Expect'=>'',
            'User-Agent'=>'Arctic-Vendor v1.0'
          })
        .to_return(status: 200, body: "", headers: {})
      instance.update_order 1, { id: 2, a: :b }
    end
  end

  describe '#update_order_line' do
    it 'calls the right endpoint' do
      stub_request(:patch, "http://localhost:5000/v1/vendors/shops/1/orders/2/order_lines/3")
        .with(
            body: { status: 'Invoiced' }.to_json,
            headers: {
            'Accept'=>'application/json',
            'Authorization'=>'Basic aWQ6dG9rZW4=',
            'Content-Type'=>'application/json',
            'Expect'=>'',
            'User-Agent'=>'Arctic-Vendor v1.0'
          })
        .to_return(status: 200, body: "", headers: {})
      instance.update_order_line 1, 2, 3, { status: 'Invoiced' }
    end
  end

  describe '#lookup_order' do
    it 'calls the right endpoint' do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/orders/2").
        with(
          headers: {
         'Accept'=>'application/json',
         'Authorization'=>'Basic aWQ6dG9rZW4=',
         'Content-Type'=>'application/json',
         'Expect'=>'',
         'User-Agent'=>'Arctic-Vendor v1.0'
          }).
        to_return(status: 200, body: "", headers: {})
      instance.lookup_order 1, 2
    end
  end

  describe '#create_order' do
    it 'calls the right endpoint' do
      stub_request(:post, "http://localhost:5000/v1/vendors/shops/1/orders").
        with(
          body: "{\"id\":1,\"address\":\"somewhere 5\"}",
          headers: {
         'Accept'=>'application/json',
         'Authorization'=>'Basic aWQ6dG9rZW4=',
         'Content-Type'=>'application/json',
         'Expect'=>'',
         'User-Agent'=>'Arctic-Vendor v1.0'
          }).
        to_return(status: 200, body: "", headers: {})

      instance.create_order 1, { id: 1, address: 'somewhere 5' }
    end
  end

  describe '#create_product' do
    it 'calls the right endpoint' do
       stub_request(:post, "http://localhost:5000/v1/vendors/shops/1/products").
         with(
           body: "{\"id\":2,\"a\":\"b\"}",
           headers: {
          'Accept'=>'application/json',
          'Authorization'=>'Basic aWQ6dG9rZW4=',
          'Content-Type'=>'application/json',
          'Expect'=>'',
          'User-Agent'=>'Arctic-Vendor v1.0'
           }).
         to_return(status: 200, body: "", headers: {})
      instance.create_product 1, { id: 2, a: :b }
    end
  end

  describe '#orders' do
    it 'calls the right endpoint' do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/orders?since")
        .with(
          headers: {
          'Accept'=>'application/json',
          'Authorization'=>'Basic aWQ6dG9rZW4=',
          'Content-Type'=>'application/json',
          'Expect'=>'',
          'User-Agent'=>'Arctic-Vendor v1.0'
        })
        .to_return(status: 200, body: "", headers: {})
      instance.orders(1)
    end

    it 'calls the right endpoint since' do
      date = 1.minute.ago.httpdate
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1/orders?since=#{date}")
        .with(
          headers: {
          'Accept'=>'application/json',
          'Authorization'=>'Basic aWQ6dG9rZW4=',
          'Content-Type'=>'application/json',
          'Expect'=>'',
          'User-Agent'=>'Arctic-Vendor v1.0'
        })
        .to_return(status: 200, body: "", headers: {})
      instance.orders(1, since: date)
    end
  end

  describe '#request' do
    subject do
      instance.send :request, method,
        endpoint,
        params: params,
        body: body
    end

    let(:params) { { a: :b } }

    let(:body) { { c: :d } }

    let(:method) { :get }

    let(:endpoint) { 'products' }

    it 'calls the connection' do
      expect(instance.connection).to receive(:get).with(endpoint)
      subject
    end
  end

  describe '#list_shops' do
    let(:shop1) { { id: 'shop1' }.as_json }

    let(:shop2) { { id: 'shop2' }.as_json }

    let(:response) do
      {
        status: 200,
        body: {
          collection: [shop1],
          dispersal: [shop2],
        }.to_json
      }
    end

    before do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops")
        .and_return(response)
    end

    context 'without block' do
      it 'yields each of the shops' do
        expect(instance.list_shops).to match_array [shop2]
      end
    end

    context 'with block' do
      it 'yields each of the shops' do
        expect { |b| instance.list_shops(&b) }.to \
          yield_successive_args(shop2)
      end
    end

    describe 'collection type' do
      context 'without block' do
        it 'yields each of the shops' do
          expect(instance.list_shops(:collection)).to match_array [shop1]
        end
      end

      context 'with block' do
        it 'yields each of the shops' do
          expect { |b| instance.list_shops(:collection, &b) }.to \
            yield_successive_args(shop1)
        end
      end
    end
  end

  describe '#get_shop' do
    let(:shop1) { { id: 'shop1' }.as_json }

    let(:response) do
      {
        status: 200,
        body: shop1.to_json
      }
    end

    before do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops/1")
        .and_return(response)
    end

    subject { instance.get_shop(1) }

    it 'returns the shop details' do
      expect(subject).to eql shop1.as_json
    end
  end

  describe '#paginated_request' do
    let(:params) { { a: :b } }

    let(:body) { { c: :d } }

    let(:method) { :get }

    let(:endpoint) { 'products' }

    it 'yields each of the response pages' do
      initial_response = double \
        headers: {
          'Total' => 13,
          'Per-Page' => 5,
        },
        body: [1, 2, 3, 4, 5]
      expect(instance.connection).to receive(:get)
        .with(endpoint)
        .and_return initial_response

      second_response = double \
        headers: {
          'Total' => 13,
          'Per-Page' => 5,
        },
        body: [6, 7, 8, 9, 10]
      expect(instance.connection).to receive(:get)
        .with(endpoint)
        .and_return second_response

      third_response = double \
        headers: {
          'Total' => 13,
          'Per-Page' => 5,
        },
        body: [11, 12, 13]
      expect(instance.connection).to receive(:get)
        .with(endpoint)
        .and_return third_response

      args = [method, endpoint]

      options = {
        params: params,
        body: body,
      }

      expected_responses = [
        initial_response,
        second_response,
        third_response,
      ]

      expect { |b| instance.send(:paginated_request, *args, **options, &b) }.to \
        yield_successive_args(*expected_responses)
    end
  end
end
