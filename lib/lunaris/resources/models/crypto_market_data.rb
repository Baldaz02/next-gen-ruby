# frozen_string_literal: true

module Lunaris
  module Models
    class CryptoMarketData
      attr_reader :crypto, :tickers, :indicators

      def initialize(crypto, tickers, indicators)
        @crypto = crypto
        @tickers = tickers
        @indicators = indicators
      end

      def to_h
        Builders::CryptoMarketDataBuilder.new(crypto, tickers, indicators).build
      end
    end
  end
end
