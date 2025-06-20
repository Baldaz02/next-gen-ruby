# frozen_string_literal: true

module Lunaris
  module Services
    class IndicatorService
      attr_reader :indicator_obj

      INDICATOR_CLASSES = {
        trend_following: Indicators::TrendFollowing,
        momentum: Indicators::Momentum,
        volatility: Indicators::Volatility,
        volume_based: Indicators::VolumeBased,
        sentiment: Indicators::Sentiment
      }.freeze

      def initialize(tickers)
        price_data = load_data(tickers).freeze
        @indicator_obj = Models::Indicator.new(tickers: price_data)

        initialize_indicators
      end

      INDICATOR_CLASSES.each_key do |indicator|
        define_method(indicator) do
          instance_variable_get("@#{indicator}").calculate_all
        end
      end

      def calculate_all
        futures = INDICATOR_CLASSES.keys.map do |indicator|
          Concurrent::Future.execute do
            instance_variable_get("@#{indicator}").calculate_all
          end
        end

        results = futures.map(&:value).reduce({}) do |acc, struct|
          acc.merge(struct.to_h)
        end

        OpenStruct.new(results)
      end

      private

      def initialize_indicators
        INDICATOR_CLASSES.each do |indicator, klass|
          instance_variable_set("@#{indicator}", klass.new(indicator_obj))
        end
      end

      def load_data(tickers)
        tickers.map do |t|
          { date_time: t.date, open: t.open_price, high: t.high_price,
            low: t.low_price, close: t.close_price, volume: t.volume }
        end
      end
    end
  end
end
