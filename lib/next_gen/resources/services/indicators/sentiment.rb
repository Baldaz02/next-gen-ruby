# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Sentiment
        attr_reader :indicator_obj

        OPTIONS = {
          adi: { period: 14, price_key: :close },
          mfi: {}
        }.freeze

        def initialize(indicator_obj)
          @indicator_obj = indicator_obj
        end

        def calculate_all
          OpenStruct.new({
                           fgi_values: fear_greed_index,
                           adi_values: accumulation_distribution_index,
                           mfi_values: money_flow_index
                         })
        end

        def accumulation_distribution_index
          calculate_indicator(:adi)
        end

        def fear_greed_index(limit = 6)
          params = OpenStruct.new({ limit: limit })
          deep_struct(Clients::Fgi.new(params).values)
        end

        def money_flow_index
          calculate_indicator(:mfi)
        end

        private

        def deep_struct(obj)
          case obj
          when Hash
            OpenStruct.new(obj.transform_values { |v| deep_struct(v) })
          when Array
            obj.map { |v| deep_struct(v) }
          else
            obj
          end
        end

        def calculate_indicator(type, opts = nil)
          indicator_obj.calculate(type.to_s, opts || OPTIONS[type])
        end
      end
    end
  end
end
