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
        @cryptos = load_cryptos
      end

      def call
        cryptos.each do |crypto|
          tickers = fetch_ticker_data(crypto)
          Services::IndicatorService.new(tickers).calculate_all
        end
      end

      private

      def fetch_ticker_data(crypto)
        params = DEFAULT_PARAMS.merge(symbol: "#{crypto.symbol}USDT")
        client = Clients::Binance.new(OpenStruct.new(params))
        parse_data(client.candlestick, crypto)
      end

      def load_cryptos
        CSV.foreach(FILE_PATH, headers: true).map do |row|
          Models::Crypto.new(name: row['Name'], symbol: row['Symbol'])
        end
      end

      def parse_data(data, crypto)
        data.map { |entry| Models::Ticker.new(entry, crypto) }
      end
    end
  end
end
