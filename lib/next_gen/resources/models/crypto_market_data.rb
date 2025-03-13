# frozen_string_literal: true

module NextGen
  module Models
    class CryptoMarketData
      attr_reader :crypto, :tickers, :indicator_obj

      def initialize(crypto, tickers, indicators)
        @crypto = crypto
        @tickers = tickers
        @indicator_obj = Indicator.new(indicators: indicators)
      end

      def to_h
        crypto.to_h.merge({
                            data: Models::Ticker.sorted_by_date(tickers).map do |ticker|
                              ticker.to_h.merge(format_indicators(ticker.date))
                            end
                          })
      end

      private

      def datetime_builder(values)
        data = {}

        values.each_slice(2) do |indicator, index|
          indicator.instance_variables.map(&:to_s).each do |variable|
            attribute = variable.delete('@')
            next if attribute == 'date_time'

            if %w[sma ema].include?(attribute)
              suffix = index.even? ? '10' : '20'
              attribute = "#{attribute}#{suffix}"
            end

            data[attribute.to_sym] = indicator.instance_variable_get(variable)
          end
        end
        data
      end

      def format_indicators(ticker_datetime)
        %i[sma_values ema_values macd_values rsi_values sr_values tsi_values bb_values atr_values kc_values obv_values
           fgi_values].each_with_object({}) do |type, hash|
          method = type == :fgi_values ? :filter_by_today : :filter_by_datetime
          indicators = indicator_obj.indicators
          filtered_indicators = indicator_obj.send(method, indicators.send(type), ticker_datetime)

          values = type == :fgi_values ? today_builder(filtered_indicators) : datetime_builder(filtered_indicators)
          hash[type] = format_to_hash(values)
        end
      end

      def format_to_hash(values)
        return values if values.is_a?(Hash)

        values.reduce({}, :merge)
      end

      def today_builder(values)
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
