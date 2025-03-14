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

      attr_reader :cache_data, :indicators, :tickers

      def initialize(tickers: nil, indicators: nil)
        if tickers
          @tickers = tickers
          @cache_data = {}
          cache_data_by_periods(DATA_PERIOD.values.uniq)
        else
          @indicators = indicators
        end
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

      def filter_by_datetime(values, datetime, index = 0)
        unless values.any?(&:date_time)
          all_values = []

          [values.sma10, values.sma20, values.ema10, values.ema20].each_with_index do |indicator_list, index|
            all_values << filter_by_datetime(indicator_list, datetime, index) if indicator_list&.any?
          end

          return all_values.flatten
        end

        filtered_indicators = values.select { |value| value.date_time == datetime }
        [filtered_indicators, index].flatten
      end

      def filter_by_day(data, ticker_datetime)
        ticker_timestamp = ticker_datetime.to_date.to_time.to_i

        data.select { |d| d.timestamp == ticker_timestamp }
      end

      private

      def cache_data_by_periods(periods)
        periods.each { |period| cache_data[period] ||= tickers.last(period) }
      end
    end
  end
end
