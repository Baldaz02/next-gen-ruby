# frozen_string_literal: true

require 'rest-client'
require 'json'

module NextGen
  module Clients
    class Binance
      BASE_URL = 'https://api.binance.com/api/v3'

      attr_reader :logger, :params

      def initialize(params)
        @params = params
        @logger = Config::Logger.instance
      end

      def candlestick
        response = RestClient.get("#{BASE_URL}/klines", { params: candlestick_params })
        logger.info("Binance API response for #{params.symbol}: HTTP #{response.code}")
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
        map_candle = { unix_timestamp: 0, open_price: 1, high_price: 2, low_price: 3, close_price: 4, volume: 5 }

        data.map do |candle|
          candle_data = map_candle.transform_values do |index|
            candle[index].to_f
          end

          candle_data[:date] = Config::Application.timestamp_to_date(candle[0] / 1000)

          candle_data.freeze
        end
      end
    end
  end
end
