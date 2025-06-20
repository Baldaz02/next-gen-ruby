# frozen_string_literal: true

require 'csv'

module Lunaris
  module Models
    class Crypto
      DEFAULT_TICKER_PARAMS = { interval: '1h', limit: 50 }.freeze
      FILE_PATH = 'data/cryptos.csv'

      attr_reader :name, :symbol

      def initialize(params)
        @name, @symbol = params.values_at(:name, :symbol)
      end

      def self.all
        CSV.foreach(FILE_PATH, headers: true).map do |row|
          Models::Crypto.new(name: row['Name'], symbol: row['Symbol'])
        end
      end

      def tickers(params = nil)
        params = DEFAULT_TICKER_PARAMS.merge(params || {})
                                      .merge(symbol: "#{symbol}USDT")

        candles = Clients::Binance.new(params).candlestick
        candles.map { |entry| Models::Ticker.new(entry, self) }
      end

      def to_h
        {
          crypto: {
            name: name,
            symbol: symbol
          }
        }
      end
    end
  end
end
