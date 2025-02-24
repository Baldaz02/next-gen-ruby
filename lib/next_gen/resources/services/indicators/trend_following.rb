# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class TrendFollowing
        attr_reader :cache_data

        def initialize(cache_data)
          @cache_data = cache_data
        end

        def calculate_all
          OpenStruct.new({
                           sma_values: simple_moving_averages,
                           ema_values: exponential_moving_averages,
                           macd_values: moving_average_convergence_divergence,
                           rsi_values: relative_strength_index
                         })
        end

        def simple_moving_averages
          OpenStruct.new({
                           sma10: NextGen::Models::Indicator.calculate(:Sma, 10, cache_data),
                           sma20: NextGen::Models::Indicator.calculate(:Sma, 20, cache_data)
                         })
        end

        def exponential_moving_averages
          OpenStruct.new({
                           ema10: NextGen::Models::Indicator.calculate(:Ema, 10, cache_data),
                           ema20: NextGen::Models::Indicator.calculate(:Ema, 20, cache_data)
                         })
        end

        def relative_strength_index(period = 14)
          NextGen::Models::Indicator.calculate(:Rsi, period, cache_data)
        end

        def moving_average_convergence_divergence(fast_period = 12, slow_period = 26, signal_period = 9)
          options = { fast_period: fast_period, slow_period: slow_period, signal_period: signal_period,
                      price_key: :close }
          NextGen::Models::Indicator.calculate(:Macd, 34, cache_data, options: options)
        end
      end
    end
  end
end
