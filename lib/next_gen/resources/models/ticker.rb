# frozen_string_literal: true

module NextGen
  module Models
    class Ticker
      attr_reader :date, :open_price, :close_price, :high_price, :low_price, :volume, :crypto

      def initialize(candle_params, crypto)
        @date, @open_price, @close_price, @high_price, @low_price, @volume =
          %i[date open_price close_price high_price low_price volume].map { |k| candle_params[k.to_s] }

        @crypto = crypto
      end

      def self.sorted_by_date(tickers)
        tickers.sort_by { |ticker| -Time.parse(ticker.date).to_i }
      end

      def to_h
        {
          date: date,
          open_price: open_price,
          close_price: close_price,
          high_price: high_price,
          low_price: low_price,
          volume: volume
        }
      end
    end
  end
end
