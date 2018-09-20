require "spec_helper"
require 'rack/test'

class TestValidator
  attr_reader :product, :options, :errors

  def initialize(product, **options)
    @options = options
    @product = product
    @errors = {}
  end

  def valid?
    add_error :name, 'missing' if product[:name].to_s.blank?
    errors.empty?
  end

  private

    def add_error(field, error)
      @errors[field] = error
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

  describe 'POST /v1/validate' do
    let(:product) do
      {
        name: 'Product 1',
      }
    end

    let(:params) do
      {
        product: product,
      }
    end

    let(:action) do
      post '/v1/validate', params.to_json
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
    end
  end
end
