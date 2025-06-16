# frozen_string_literal: true

module Lunaris
  module Services
    module Indicators
      class BaseIndicatorService
        attr_reader :indicator_obj

        def initialize(indicator_obj)
          @indicator_obj = indicator_obj
        end

        def calculate_all
          results = self.class::OPTIONS.each_with_object({}) do |(type, opts), result|
            result[:"#{type}_values"] = calculate_indicator_for(type, opts)
          end

          OpenStruct.new(results)
        end

        private

        def calculate_indicator_for(type, opts)
          if %i[sma ema].include?(type)
            calculate_moving_average(type)
          else
            calculate_indicator(type, opts)
          end
        end

        def calculate_moving_average(type)
          OpenStruct.new(
            self.class::OPTIONS[type].transform_values { |opts| calculate_indicator(type, opts) }
          )
        end

        def calculate_indicator(type, opts = nil)
          indicator_obj.calculate(type.to_s, opts || self.class::OPTIONS[type])
        end
      end
    end
  end
end
