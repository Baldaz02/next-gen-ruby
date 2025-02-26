# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Sentiment
        attr_reader :cache_data

        def initialize(cache_data)
          @cache_data = cache_data
        end

        def calculate_all
          OpenStruct.new({
                           fgi_values: fear_greed_index,
                           adi_values: accumulation_distribution_index,
                           mfi_values: money_flow_index
                         })
        end

        def accumulation_distribution_index(period = 14)
          Models::Indicator.calculate(:Adi, period, cache_data)
        end

        def fear_greed_index
          []
        end

        def money_flow_index(period = 14)
          Models::Indicator.calculate(:Mfi, period, cache_data, options: {})
        end
      end
    end
  end
end
