# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Momentum
        attr_reader :indicator_obj

        OPTIONS = {
          rsi: { period: 14, price_key: :close},
          sr: {},
          tsi: { low_period: 13, high_period: 25, price_key: :close }
        }.freeze

        def initialize(indicator_obj)
          @indicator_obj = indicator_obj
        end

        def calculate_all
          OpenStruct.new({
                           rsi_values: relative_strength_index,
                           sr_values: stochastic_oscillator,
                           tsi_values: true_strength_index
                         })
        end

        def relative_strength_index
          calculate_indicator(:rsi)
        end

        def stochastic_oscillator
          calculate_indicator(:sr)
        end

        def true_strength_index
          calculate_indicator(:tsi)
        end

        private

        def calculate_indicator(type, opts = nil)
          indicator_obj.calculate(type.to_s, opts || OPTIONS[type])
        end
      end
    end
  end
end
