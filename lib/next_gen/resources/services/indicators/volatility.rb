# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Volatility
        attr_reader :indicator_obj

        OPTIONS = {
          bb: { period: 20, price_key: :close },
          atr: {},
          kc: {}
        }.freeze

        def initialize(indicator_obj)
          @indicator_obj = indicator_obj
        end

        def calculate_all
          OpenStruct.new(OPTIONS.to_h { |type, opts| [:"#{type}_values", calculate_indicator(type, opts)] })
        end

        private

        def calculate_indicator(type, opts)
          indicator_obj.calculate(type.to_s, opts)
        end
      end
    end
  end
end
