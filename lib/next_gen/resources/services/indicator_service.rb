# frozen_string_literal: true

require 'technical-analysis'

module NextGen
  module Services
    class IndicatorService
      CandleData = Struct.new(:date_time, :open, :high, :low, :close, :volume, keyword_init: true)

      attr_reader :price_data

      def initialize(tickers, buffer_size = 5)
        @price_data = load_data(tickers).freeze

        @cache_data = {}
        cache_data_by_periods([10, 20], buffer_size)
      end

      def simple_moving_averages
        {
          'sma10' => calculate_indicator(:Sma, 10),
          'sma20' => calculate_indicator(:Sma, 20),
        }.freeze
      end

      def exponential_moving_averages
        {
          'ema10' => calculate_indicator(:Ema, 10),
          'ema20' => calculate_indicator(:Ema, 20),
        }
      end

      private

      def load_data(tickers)
        tickers.map do |t|
          CandleData.new(date_time: t.date, open: t.open_price, high: t.high_price,
                         low: t.low_price, close: t.close_price, volume: t.volume)
        end
      end

      def cache_data_by_periods(periods, buffer_size)
        periods.each do |period|
          @cache_data[period] ||= price_data.last(period + buffer_size).map(&:to_h)
        end
      end

      def calculate_indicator(indicator_type, period)
        indicator_class = Object.const_get("TechnicalAnalysis::#{indicator_type}")
        indicator_class.calculate(@cache_data[period], period: period, price_key: :close)
      end
    end
  end
end
