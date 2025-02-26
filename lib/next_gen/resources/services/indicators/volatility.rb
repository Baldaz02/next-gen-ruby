# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Volatility
        attr_reader :cache_data

        def initialize(cache_data)
          @cache_data = cache_data
        end

        def calculate_all
          OpenStruct.new({
                           bb_values: bollinger_bands,
                           atr_values: average_true_range,
                           kc_values: keltner_channel
                         })
        end

        def average_true_range(period = 14)
          Models::Indicator.calculate(:Atr, period, cache_data, options: {})
        end

        def bollinger_bands(period = 20)
          Models::Indicator.calculate(:Bb, period, cache_data)
        end

        def keltner_channel(period = 20)
          Models::Indicator.calculate(:Kc, period, cache_data, options: {})
        end
      end
    end
  end
end
