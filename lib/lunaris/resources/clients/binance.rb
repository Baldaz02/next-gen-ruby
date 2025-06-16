# frozen_string_literal: true

require 'rest-client'
require 'json'

module Lunaris
  module Clients
    class Binance
      attr_reader :client, :params

      def initialize(params)
        @params = params
        @client = Clients::Aws.new
      end

      def candlestick
        lambda_params = { lambda: { class: 'Clients::Binance', method: 'candlestick' } }
        client.invoke(lambda_params.merge(params))
      end
    end
  end
end
