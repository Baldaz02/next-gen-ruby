# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Momentum
        attr_reader :cache_data

        def initialize(cache_data)
          @cache_data = cache_data
        end

        def calculate_all
          OpenStruct.new({
                           rsi_values: relative_strength_index,
                           sr_values: stochastic_oscillator,
                           tsi_values: true_strength_index
                         })
        end

        def stochastic_oscillator(period = 14)
          Models::Indicator.calculate(:Sr, period, cache_data, options: {})
        end

        def true_strength_index(short_period = 13, long_period = 25)
          options = { low_period: short_period, high_period: long_period, price_key: :close }
          Models::Indicator.calculate(:Tsi, 38, cache_data, options: options)
        end

        def relative_strength_index(period = 14)
          Models::Indicator.calculate(:Rsi, period, cache_data)
        end
      end
    end
  end
end
