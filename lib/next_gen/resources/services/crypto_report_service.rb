# frozen_string_literal: true

require 'csv'
require 'ostruct'

module NextGen
  module Services
    class CryptoReportService
      DEFAULT_PARAMS = { interval: '1h', limit: 50 }.freeze
      FILE_PATH = 'data/cryptos.csv'.freeze

      attr_reader :cryptos

      def initialize
        @cryptos = []

        CSV.foreach(FILE_PATH, headers: true) do |row|
          params = { name: row['Name'], symbol: row['Symbol'] }
          @cryptos << Models::Crypto.new(params)
        end
      end

      def call
        cryptos.each do |crypto|
          params = OpenStruct.new(DEFAULT_PARAMS.merge({ symbol: "#{crypto.symbol}USDT" }))
          client = Clients::Binance.new(OpenStruct.new(params))
          data = client.candlestick
          tickers = parse_data(data, crypto)

          Services::IndicatorService.new(tickers).calculate_all
        end
      end

      private

      def parse_data(data, crypto)
        data.map do |entry|
          Models::Ticker.new(entry, crypto)
        end
      end
    end
  end
end
