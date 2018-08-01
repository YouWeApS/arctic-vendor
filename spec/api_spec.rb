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
    let(:shop1) { { id: 'shop1' } }

    let(:shop2) { { id: 'shop2' } }

    let(:response) do
      {
        status: 200,
        body: [shop1, shop2],
      }
    end

    before do
      stub_request(:get, "http://localhost:5000/v1/vendors/shops")
        .and_return(response)
    end

    context 'without block' do
      it 'yields each of the shops' do
        expect(instance.list_shops).to match_array [shop1, shop2]
      end
    end

    context 'with block' do
      it 'yields each of the shops' do
        expect { |b| instance.list_shops(&b) }.to \
          yield_successive_args(shop1, shop2)
      end
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
