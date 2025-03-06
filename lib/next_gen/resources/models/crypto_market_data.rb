# frozen_string_literal: true

module NextGen
  module Models
    class CryptoMarketData
      attr_reader :crypto, :tickers, :indicators

      def initialize(crypto, tickers, indicators)
        @crypto = crypto
        @tickers = tickers
        @indicators = indicators
      end

      def to_h
        {
          crypto: {
            name: crypto.name,
            symbol: crypto.symbol
          },
          data: tickers.to_a.sort_by { |ticker| -ticker.date.to_time.to_i }.map do |ticker|
            {
              date: ticker.date,
              open_price: ticker.open_price,
              close_price: ticker.close_price,
              high_price: ticker.high_price,
              low_price: ticker.low_price,
              volume: ticker.volume
            }.merge(format_indicators(ticker.date))
          end
        }
      end

      private

      def format_indicators(ticker_datetime)
        {
          sma_values: filter_by_datetime(indicators.sma_values, ticker_datetime),
          ema_values: filter_by_datetime(indicators.ema_values, ticker_datetime),
          macd_values: filter_by_datetime(indicators.macd_values, ticker_datetime),
          rsi_values: filter_by_datetime(indicators.rsi_values, ticker_datetime),
          sr_values: filter_by_datetime(indicators.sr_values, ticker_datetime),
          tsi_values: filter_by_datetime(indicators.tsi_values, ticker_datetime),
          bb_values: filter_by_datetime(indicators.bb_values, ticker_datetime),
          atr_values: filter_by_datetime(indicators.atr_values, ticker_datetime),
          kc_values: filter_by_datetime(indicators.kc_values, ticker_datetime),
          obv_values: filter_by_datetime(indicators.obv_values, ticker_datetime),
          fgi_values: filter_by_today(indicators.fgi_values, ticker_datetime)
        }
      end

      def filter_by_datetime(values, datetime, index = 0)
        unless values.any?(&:date_time)
          all_values = []

          [values.sma10, values.sma20, values.ema10, values.ema20].each_with_index do |indicator_list, index|
            if indicator_list&.any?
              all_values << filter_by_datetime(indicator_list, datetime, index)
            end
          end

          return all_values.flatten
        end

        filtered_indicators = values.select { |value| value.date_time == datetime }
        return [] if filtered_indicators.nil? || filtered_indicators.empty?

        data = {}
        filtered_indicators.each do |indicator|
          indicator.instance_variables.each do |var|
            attribute = "#{var}".to_s.delete('@')
            next if attribute == 'date_time'

            if attribute == 'sma' || attribute == 'ema'
              suffix = (index % 2 == 0) ? '10' : '20'
              attribute = "#{attribute}#{suffix}"
            end

            data[attribute.to_sym] = indicator.instance_variable_get(var)
          end
        end
        data
      end

      def filter_by_today(data, ticker_datetime)
        ticker_start_of_day = DateTime.new(ticker_datetime.year, ticker_datetime.month, ticker_datetime.day)
        ticker_timestamp = ticker_start_of_day.to_time.to_i

        filtered_data = data.select do |d|
          d.timestamp.to_i == ticker_timestamp
        end

        filtered_data.map do |d|
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
