# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class TrendFollowing
        attr_reader :indicator_obj

        OPTIONS = {
          sma: { 'sma10' => { period: 10, price_key: :close }, 'sma20' => { period: 20, price_key: :close } },
          ema: { 'ema10' => { period: 10, price_key: :close }, 'ema20' => { period: 20, price_key: :close } },
          macd: { fast_period: 12, slow_period: 26, signal_period: 9, price_key: :close }
        }.freeze

        def initialize(indicator_obj)
          @indicator_obj = indicator_obj
        end

        def calculate_all
          OpenStruct.new(
            sma_values: moving_average(:sma),
            ema_values: moving_average(:ema),
            macd_values: calculate_indicator(:macd)
          )
        end

        private

        def moving_average(type)
          OpenStruct.new(OPTIONS[type].transform_values { |opts| calculate_indicator(type, opts) })
        end

        def calculate_indicator(type, opts = nil)
          indicator_obj.calculate(type.to_s, opts || OPTIONS[type])
        end
      end
    end
  end
end
