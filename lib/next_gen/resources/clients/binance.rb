# frozen_string_literal: true

require 'rest-client'
require 'json'

module NextGen
  module Clients
    class Binance
      attr_reader :client, :logger, :params

      def initialize(params)
        @params = params
        @client = Clients::Aws.new
        @logger = Config::Logger.instance
      end

      def candlestick
        lambda_params = { lambda: { class: 'Clients::Binance', method: 'candlestick' } }

        response = client.invoke({
                                   function_name: 'NextGen',
                                   invocation_type: 'RequestResponse',
                                   log_type: 'Tail',
                                   payload: JSON.generate(lambda_params.merge(params))
                                 })

        JSON.parse(response.payload.string)
      end
    end
  end
end
