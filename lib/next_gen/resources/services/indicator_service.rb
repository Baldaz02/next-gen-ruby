# frozen_string_literal: true

require 'technical-analysis'
require 'byebug'

module NextGen
  module Services
    class IndicatorService
      CandleData = Struct.new(:date_time, :open, :high, :low, :close, :volume, keyword_init: true)

      attr_reader :price_data

      def initialize(tickers, buffer_size = 5)
        @price_data = load_data(tickers).freeze

        @cache_data = {}
        cache_data_by_periods([10, 14, 20, 34], buffer_size)
      end

      def simple_moving_averages
        {
          'sma10' => calculate_indicator(:Sma, 10),
          'sma20' => calculate_indicator(:Sma, 20)
        }.freeze
      end

      def exponential_moving_averages
        {
          'ema10' => calculate_indicator(:Ema, 10),
          'ema20' => calculate_indicator(:Ema, 20)
        }
      end

      def relative_strength_index(period = 14)
        calculate_indicator(:Rsi, period)
      end

      def moving_average_convergence_divergence(fast_period = 12, slow_period = 26, signal_period = 9)
        options = { fast_period: fast_period, slow_period: slow_period, signal_period: signal_period , price_key: :close }
        calculate_indicator(:Macd, 34, options: options)
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

      def calculate_indicator(indicator_type, period, options: nil)
        indicator_class = Object.const_get("TechnicalAnalysis::#{indicator_type}")

        if options
          indicator_class.calculate(@cache_data[period], options)
        else
          indicator_class.calculate(@cache_data[period], period: period, price_key: :close)
        end
      end
    end
  end
end
