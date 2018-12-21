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

    helpers do
      def logger
        Arctic.logger
      end
    end

    use GrapeLogging::Middleware::RequestLogger,
      logger: Arctic.logger,
      include: [ GrapeLogging::Loggers::Response.new,
                 GrapeLogging::Loggers::FilterParameters.new,
                 GrapeLogging::Loggers::ClientEnv.new,
                 GrapeLogging::Loggers::RequestHeaders.new ]

    # Use the same credentials for incomming traffic as when connecting to the
    # Core API.
    http_basic do |id, token|
      (id == ENV.fetch('VENDOR_ID') && token == ENV.fetch('VENDOR_TOKEN')).tap do |result|
        logger.debug "Authenticating #{id}: #{result}"
      end
    end

    desc "Ping"
    get do
      { ping: :pong }
    end

    desc "Validate a single product"
    params do
      requires :product, type: Hash, desc: "Product information"
      optional :options, type: Hash, desc: "Additional options", default: {}
    end
    post :validate do
      sku = params[:product][:sku]

      begin
        klass = Arctic.validator_class.to_s.classify.constantize
        logger.debug "Validating with: #{klass}"
        validator = klass.new params[:product], params[:options]
        status validator.valid? ? 200 : 400
        logger.info "Validated Product(#{sku}): #{validator.errors.empty?}"
        logger.info "Validation errors for Product(#{sku}): #{validator.errors}" if validator.errors.any?
        validator.errors
      rescue => e
        logger.debug "Rescueing from #{e.class}: #{e.message}"
        e.backtrace.collect { |l| logger.debug l }
        logger.error "Validating Product(#{sku}) raised an exception (#{e.class}): #{e.message}"
        status 400
        {
          invalid_request: 'Malformatted request'
        }
      end
    end
  end
end
