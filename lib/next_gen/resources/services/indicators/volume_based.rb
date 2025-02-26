# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class VolumeBased
        attr_reader :cache_data

        def initialize(cache_data)
          @cache_data = cache_data
        end

        def calculate_all
          OpenStruct.new({
                           obv_values: on_balance_volume,
                           cmf_values: chaikin_money_flow,
                           vwap_values: volume_weighted_average_price
                         })
        end

        def chaikin_money_flow(period = 20)
          Models::Indicator.calculate(:Cmf, period, cache_data, options: {})
        end

        def on_balance_volume(period = 20)
          Models::Indicator.calculate(:Obv, period, cache_data)
        end
        
        def volume_weighted_average_price(period = 20)
          Models::Indicator.calculate(:Vwap, period, cache_data)
        end
      end
    end
  end
end
