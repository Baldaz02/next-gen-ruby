# frozen_string_literal: true

module NextGen
  module Services
    class IndicatorService
      attr_reader :price_data, :cache_data

      def initialize(tickers, buffer_size = 5)
        @price_data = load_data(tickers).freeze
        @cache_data = {}
        cache_data_by_periods([10, 14, 20, 34, 38], buffer_size)

        @trend_following = Indicators::TrendFollowing.new(@cache_data)
        @momentum = Indicators::Momentum.new(@cache_data)
      end

      def trend_following
        @trend_following.calculate_all
      end

      def momentum
        @momentum.calculate_all
      end

      private

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
