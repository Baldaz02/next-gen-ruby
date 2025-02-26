# frozen_string_literal: true

require 'technical-analysis'

module NextGen
  module Models
    class Indicator
      TYPE_PERIOD = {
        sma10: 15,
        sma20: 25,
        ema10: 15,
        ema20: 25,
        macd: 39,
        rsi: 20,
        sr: 21,
        tsi: 43
      }.freeze

      attr_reader :cache_data, :tickers

      def initialize(tickers)
        @cache_data = {}
        @tickers = tickers

        cache_data_by_periods(TYPE_PERIOD.values.uniq)
      end

      def calculate(type, options = {})
        indicator_class = Object.const_get("TechnicalAnalysis::#{type.capitalize}")
        key = :"#{type}#{options[:period]}"
        period = TYPE_PERIOD[key] || TYPE_PERIOD[type.to_sym]

        indicator_class.calculate(cache_data[period], options)
      end

      private

      def cache_data_by_periods(periods)
        periods.each { |period| cache_data[period] ||= tickers.last(period) }
      end
    end
  end
end
