# frozen_string_literal: true

require 'rest-client'
require 'json'

module NextGen
  module Clients
    class Binance
      BASE_URL = 'https://api.binance.com/api/v3'

      attr_reader :params

      def initialize(params)
        @params = params
      end

      def candlestick
        response = RestClient.get("#{BASE_URL}/klines", { params: candlestick_params })
        candlestick_response(response)
      end

      private

      def candlestick_params
        {
          symbol: @params.symbol,
          interval: @params.interval,
          startTime: @params.timestamps[:start],
          endTime: @params.timestamps[:end],
          limit: @params.limit
        }.compact
      end

      def candlestick_response(response)
        data = JSON.parse(response.body)

        data.map { |candle| { open_time: candle[0], price: candle[1].to_f } }
      end
    end
  end
end
