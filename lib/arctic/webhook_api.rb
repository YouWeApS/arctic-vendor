require_relative 'logger'
require 'grape'
require 'grape_logging'

module Arctic
  class WebhookApi < Grape::API
    helpers do
      def init_params
        @params = JSON.parse env['api.request.input']
        @is_dd, @shop_id = get_shop
      end

      def webhook_logger
        @webhook_logger ||= Logger.new 'log/webhook.log'
      end

      def server_answer
        webhook_logger.info "Shop ID: #{env['rack.request.query_hash']['shop_id']} | Data: #{env['api.request.body']}"

        init_params
        unless @is_dd
          [200, {"Content-Type" => "text/html"}, ["Not Done"]]
        end
        @params.each do |params|
          if isIdentifierNotChanged(params) && isCountChanged(params)
            update_product_count(params)
          end
        end
        [200, {"Content-Type" => "text/html"}, ["Done"]]
      end

      def isCountChanged(params)
        if params['newValues'] != nil
          params['newValues']['stockCountDelta'].to_i != 0
        end
      end

      def isIdentifierNotChanged(params)
        if (params['newValues'] != nil) && (params['oldValues'] != nil)
          params['oldValues']['objectIdentifier'] == params['newValues']['objectIdentifier']
        end
      end

      def product(params)
        if params['oldValues'] != nil
          encode(params['oldValues']['objectIdentifier'])
        end
      end

      def data(params)
        if params['newValues'] != nil
          { count: params['newValues']['stockCount'] }
        end
      end

      def get_shop
        url = env['REQUEST_URI']
        return url.include?('dandomain.arctic-project.io'), url[(url.index('shop_id') + 8), 36]
      end

      def encode(text)
        result = URI.encode(text).gsub '/', '%2F'
        replacements = [ [' ', "%20"], ["(", "%28"], [")", "%29"], ["|", "%7C"] , [".", "%2E"]]
        replacements.each {|replacement| result.gsub!(replacement[0], replacement[1])}
        result
      end

      def update_product_count(params)
        core_api = Arctic::Vendor::Dispersal::API.new
        core_api.update_product_stock(@shop_id, product(params), data(params))
      end
    end

    resource :webhooks do
      post :products do
        server_answer
      end
    end
  end
end
