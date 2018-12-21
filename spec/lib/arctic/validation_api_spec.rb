require "spec_helper"
require 'rack/test'

class TestValidator
  attr_reader :product, :options, :errors

  def initialize(product, options)
    @options = options.as_json
    @product = product.as_json
    @errors = {}
  end

  def valid?
    add_error :name, 'missing' if product['name'].to_s.blank?
    add_error :shop, 'missing' unless options['shop'].is_a? Hash
    errors.empty?
  end

  private

    def add_error(field, error)
      @errors[field] = error
    end
end

class InvalidTestValidator < TestValidator
  def initialize(product, **options)
    super product, **options
  end
end

Arctic.validator_class = TestValidator

RSpec.describe Arctic::ValidationApi do
  include Rack::Test::Methods

  def app
    described_class
  end

  before do
    header 'Accept', 'application/json'
    header 'Content-Type', 'application/json'
  end

  describe 'POST /validate' do
    let(:product) do
      {
        name: 'Product 1',
      }
    end

    let(:shop) do
      {
        config: {
          a: :b,
        },
      }
    end

    let(:params) do
      {
        product: product,
        options: {
          shop: shop,
        },
      }
    end

    let(:action) do
      post '/validate', params.to_json
    end

    context 'invalid validator class' do
      include_context :authenticated

      before { Arctic.validator_class = InvalidTestValidator }
      after { Arctic.validator_class = TestValidator }

      it 'returns 400' do
        action
        expect(last_response.status).to eq(400)
      end

      it 'returns the correct error' do
        action
        expect(last_response.body).to eql({ invalid_request: 'Malformatted request' }.to_json)
      end
    end

    context 'no credentials' do
      it 'returns 401' do
        action
        expect(last_response.status).to eq(401)
      end
    end

    context 'valid credentials' do
      include_context :authenticated

      it 'returns 200' do
        action
        expect(last_response.status).to eq(200)
      end

      it 'returns an empty object' do
        action
        expect(last_response.body).to eql({}.to_json)
      end

      context 'missing product' do
        before { params.delete :product }

        it 'returns 400' do
          action
          expect(last_response.status).to eq(400)
        end
      end

      context 'invalid product' do
        before { product.delete :name }

        it 'returns 400' do
          action
          expect(last_response.status).to eq(400)
        end

        it 'returns the correct error' do
          action
          expect(last_response.body).to eql({ name: :missing }.to_json)
        end
      end

      context 'invalid options' do
        let(:shop) { 'hello' }

        it 'returns 400' do
          action
          expect(last_response.status).to eq(400)
        end

        it 'returns the correct error' do
          action
          expect(last_response.body).to eql({ shop: :missing }.to_json)
        end
      end
    end
  end
end
