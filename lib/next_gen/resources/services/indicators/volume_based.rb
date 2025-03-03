# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class VolumeBased
        attr_reader :indicator_obj

        OPTIONS = {
          obv: { period: 20, price_key: :close },
          cmf: { period: 20 },
          vwap: {}
        }.freeze

        INDICATORS = %i[obv cmf vwap].freeze

        def initialize(indicator_obj)
          @indicator_obj = indicator_obj
        end

        def calculate_all
          OpenStruct.new(INDICATORS.each_with_object({}) do |indicator, result|
            result[:"#{indicator}_values"] = calculate_indicator(indicator)
          end)
        end

        private

        def calculate_indicator(type)
          indicator_obj.calculate(type.to_s, OPTIONS.fetch(type, {}))
        end
      end
    end
  end
end
