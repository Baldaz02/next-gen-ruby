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
          startTime: @params.timestamps&.dig(:start),
          endTime: @params.timestamps&.dig(:end),
          limit: @params.limit
        }.compact
      end

      def candlestick_response(response)
        data = JSON.parse(response.body)

        data.map do |candle|
          timestamp = candle[0]
          NextGen::Config::Application.timestamp_to_date(timestamp / 1000)

          {
            unix_timestamp: timestamp,
            date: NextGen::Config::Application.timestamp_to_date(timestamp / 1000),
            open_price: candle[1].to_f,
            high_price: candle[2].to_f,
            low_price: candle[3].to_f,
            close_price: candle[4].to_f,
            volume: candle[5].to_f
          }.freeze
        end
      end
    end
  end
end
