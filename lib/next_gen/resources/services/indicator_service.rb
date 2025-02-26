# frozen_string_literal: true

module NextGen
  module Services
    class IndicatorService
      attr_reader :price_data, :cache_data

      INDICATOR_CLASSES = {
        trend_following: Indicators::TrendFollowing,
        momentum: Indicators::Momentum,
        volatility: Indicators::Volatility,
        volume_based: Indicators::VolumeBased,
        sentiment: Indicators::Sentiment
      }.freeze

      def initialize(tickers, buffer_size = 5)
        @price_data = load_data(tickers).freeze
        @cache_data = {}
        cache_data_by_periods([10, 14, 20, 34, 38], buffer_size)

        initialize_indicators
      end

      INDICATOR_CLASSES.keys.each do |indicator|
        define_method(indicator) do
          instance_variable_get("@#{indicator}").calculate_all
        end
      end

      private

      def initialize_indicators
        INDICATOR_CLASSES.each do |indicator, klass|
          instance_variable_set("@#{indicator}", klass.new(@cache_data))
        end
      end

      def load_data(tickers)
        tickers.map do |t|
          { date_time: t.date, open: t.open_price, high: t.high_price,
            low: t.low_price, close: t.close_price, volume: t.volume }
        end
      end

      def cache_data_by_periods(periods, buffer_size)
        periods.each { |period| @cache_data[period] ||= price_data.last(period + buffer_size) }
      end
    end
  end
end
