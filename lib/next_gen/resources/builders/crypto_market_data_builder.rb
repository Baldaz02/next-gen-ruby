# frozen_string_literal: true

module NextGen
  module Builders
    class CryptoMarketDataBuilder
      attr_reader :crypto, :tickers, :indicator_obj

      INDICATOR_TYPES = %i[sma_values ema_values macd_values rsi_values sr_values tsi_values bb_values atr_values
                           kc_values obv_values fgi_values].freeze

      def initialize(crypto, tickers, indicators)
        @crypto = crypto
        @tickers = tickers
        @indicator_obj = Models::Indicator.new(indicators: indicators)
      end

      def build
        crypto.to_h.merge(data: build_tickers_data)
      end

      private

      def build_tickers_data
        Models::Ticker.sorted_by_date(tickers).map do |ticker|
          ticker_data(ticker)
        end
      end

      def build_values(type, filtered_indicators)
        case type
        when :fgi_values
          day_builder(filtered_indicators)
        else
          datetime_builder(filtered_indicators)
        end
      end

      def datetime_builder(values)
        values.each_slice(2).with_object({}) do |(indicator, index), data|
          process_indicator(indicator, index, data)
        end
      end

      def filter_indicators(type, ticker_datetime)
        method = type == :fgi_values ? :filter_by_day : :filter_by_datetime
        indicator_obj.send(method, indicator_obj.indicators.send(type), ticker_datetime)
      end

      def format_attribute(variable, index)
        attribute = variable.to_s.delete('@').to_sym
        attribute = format_sma_ema(attribute, index) if %i[sma ema].include?(attribute)
        attribute
      end

      def format_indicators(ticker_datetime)
        INDICATOR_TYPES.each_with_object({}) do |type, hash|
          filtered_indicators = filter_indicators(type, ticker_datetime)
          hash[type] = format_to_hash(build_values(type, filtered_indicators))
        end
      end

      def format_sma_ema(attribute, index)
        suffix = (index.even? ? '10' : '20')
        :"#{attribute}#{suffix}"
      end

      def format_to_hash(values)
        return values if values.is_a?(Hash)

        values.reduce({}, :merge)
      end

      def process_indicator(indicator, index, data)
        indicator.instance_variables.each do |variable|
          attribute = format_attribute(variable, index)
          next if attribute == :date_time

          data[attribute] = indicator.instance_variable_get(variable)
        end
      end

      def ticker_data(ticker)
        ticker.to_h.merge(format_indicators(ticker.date))
      end

      def day_builder(values)
        values.map do |d|
          {
            value: d.value,
            value_classification: d.value_classification,
            timestamp: Config::Application.timestamp_to_date(d.timestamp.to_i),
            time_until_update: d.time_until_update
          }
        end
      end
    end
  end
end
