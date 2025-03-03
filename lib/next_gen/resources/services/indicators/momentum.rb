# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Momentum
        attr_reader :indicator_obj

        OPTIONS = {
          rsi: { period: 14, price_key: :close },
          sr: {},
          tsi: { low_period: 13, high_period: 25, price_key: :close }
        }.freeze

        def initialize(indicator_obj)
          @indicator_obj = indicator_obj
        end

        def calculate_all
          OpenStruct.new(OPTIONS.transform_keys { |type| :"#{type}_values" }
                               .transform_values { |opts| calculate_indicator(opts) })
        end

        private

        def calculate_indicator(opts)
          type = opts.empty? ? :sr : OPTIONS.key(opts)
          indicator_obj.calculate(type.to_s, opts)
        end
      end
    end
  end
end
