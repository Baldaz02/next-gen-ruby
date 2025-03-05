# frozen_string_literal: true

module NextGen
  module Models
    class CryptoMarketData
      attr_reader :crypto, :tickers, :indicators

      def initialize(crypto, tickers, indicators)
        @crypto = crypto
        @tickers = tickers
        @indicators = indicators
      end

      def to_json(*_args)
        {
          crypto: {
            name: crypto.name,
            symbol: crypto.symbol
          },
          data: tickers.map do |ticker|
            {
              date: ticker.date,
              open_price: ticker.open_price,
              close_price: ticker.close_price,
              high_price: ticker.high_price,
              low_price: ticker.low_price,
              volume: ticker.volume
            }
          end
        }.to_json
      end
    end
  end
end
