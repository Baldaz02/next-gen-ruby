# frozen_string_literal: true

require 'technical-analysis'

module NextGen
  module Services
    class IndicatorService
      CandleData = Struct.new(:date_time, :open, :high, :low, :close, :volume, keyword_init: true)

      attr_reader :price_data

      def initialize(tickers)
        @price_data = load_data(tickers)
      end

      def calculate_indicator(type, period, price_key = :close)
        return nil if price_data.size < period

        indicator_class = Object.const_get("TechnicalAnalysis::#{type.capitalize}")
        indicator_class.calculate(price_data.map(&:to_h), period: period, price_key: price_key)
      end

      def simple_moving_averages
        {
          'sma10' => calculate_indicator('sma', 10)&.first,
          'sma20' => calculate_indicator('sma', 20)&.first
        }
      end

      private

      def load_data(tickers)
        tickers.map do |t|
          CandleData.new(date_time: t.date, open: t.open_price, high: t.high_price,
                         low: t.low_price, close: t.close_price, volume: t.volume)
        end
      end
    end
  end
end
