require_relative 'logger'
require 'grape'
require 'grape_logging'

module Arctic
  def validator_class
    @validator_class || :missing_validator_class
  end
  module_function :validator_class

  def validator_class=(klass)
    @validator_class = klass
  end
  module_function :validator_class=

  class ValidationApi < Grape::API
    format :json

    use GrapeLogging::Middleware::RequestLogger

    helpers do
      def logger
        Arctic.logger
      end
    end

    # Use the same credentials for incomming traffic as when connecting to the Core API
    http_basic do |id, token|
      (id == ENV.fetch('VENDOR_ID') && token == ENV.fetch('VENDOR_TOKEN')).tap do |result|
        logger.debug "Authenticating #{id}: #{result}"
      end
    end

    desc 'Run products disperse'
    post :disperse do
      status 501
      { request: 'Deprecated' }
    end

    desc 'Ping'
    get do
      { ping: :pong }
    end

    desc 'Validate a single product'
    params do
      requires :product, type: Hash, desc: 'Product information'
      optional :options, type: Hash, desc: 'Additional options', default: {}
    end
    post :validate do
      sku = params[:product][:sku]

      begin
        validator = Arctic.validator_class.new params[:product], params[:options]

        status validator.valid? ? 200 : 400

        logger.info "Validated Product(#{sku}): #{validator.errors.empty?}"
        logger.info "Validation errors for Product(#{sku}): #{validator.errors}" if validator.errors.any?

        validator.errors
      rescue => e
        logger.error "Validating Product(#{sku}) raised an exception (#{e.class}): #{e.message}. " \
                     "Backtrace: #{e.backtrace.inspect}"

        status 400
        { invalid_request: 'Failed to validate product' }
      end
    end
  end
end
