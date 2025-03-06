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

      def self.filter_by_datetime(values, datetime, index = 0)
        return [] unless values.any?(&:date_time)

        filtered_indicators = values.select { |value| value.date_time == datetime }
        return [] if filtered_indicators.empty?

        filtered_indicators.each_with_object({}).with_index do |(indicator, data), idx|
          indicator.instance_variables.each do |var|
            attribute = var.to_s.delete('@')
            next if attribute == 'date_time'

            attribute = adjust_attribute(attribute, idx)
            data[attribute.to_sym] = indicator.instance_variable_get(var)
          end
        end
      end

      def self.filter_by_today(data, ticker_datetime)
        ticker_start_of_day = DateTime.new(ticker_datetime.year, ticker_datetime.month, ticker_datetime.day)
        ticker_timestamp = ticker_start_of_day.to_time.to_i

        data.select { |d| d.timestamp == ticker_timestamp }.map do |d|
          {
            value: d.value.to_i,
            value_classification: d.value_classification,
            timestamp: Config::Application.timestamp_to_date(d.timestamp.to_i),
            time_until_update: d.time_until_update&.to_i
          }
        end
      end

      private

      def self.adjust_attribute(attribute, index)
        return attribute unless %w[sma ema].include?(attribute)

        suffix = (index.even? ? '10' : '20')
        "#{attribute}#{suffix}"
      end

      def cache_data_by_periods(periods)
        periods.each { |period| cache_data[period] ||= tickers.last(period) }
      end
    end
  end
end
