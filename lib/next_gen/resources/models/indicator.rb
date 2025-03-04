# frozen_string_literal: true

require 'technical-analysis'

module NextGen
  module Models
    class Indicator
      DATA_PERIOD = {
        adi: 20, atr: 20, bb: 25, cmf: 25,
        ema10: 15, ema20: 25, kc: 15, macd: 39,
        mfi: 20, obv: 20, rsi: 20, sma10: 15,
        sma20: 25, sr: 21, tsi: 43, vwap: 25
      }.freeze

      attr_reader :cache_data, :tickers

      def initialize(tickers)
        @cache_data = {}
        @tickers = tickers

        cache_data_by_periods(DATA_PERIOD.values.uniq)
      end

      def calculate(type, options = {})
        indicator_class = Object.const_get("TechnicalAnalysis::#{type.capitalize}")
        key = :"#{type}#{options[:period]}"
        period = DATA_PERIOD[type.to_sym] || DATA_PERIOD[key]

        if %i[adi obv vwap].map(&:to_s).include?(type)
          indicator_class.calculate(cache_data[period])
        else
          indicator_class.calculate(cache_data[period], options)
        end
      end

      private

      def cache_data_by_periods(periods)
        periods.each { |period| cache_data[period] ||= tickers.last(period) }
      end
    end
  end
end
