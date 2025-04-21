# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Sentiment < BaseIndicatorService
        OPTIONS = {
          adi: { period: 14, price_key: :close },
          mfi: {}
        }.freeze

        def calculate_all
          OpenStruct.new({
                           fgi_values: fear_greed_index,
                           adi_values: calculate_indicator(:adi),
                           mfi_values: calculate_indicator(:mfi)
                         })
        end

        def fear_greed_index(limit = 6)
          params = { limit: limit }
          deep_struct(Clients::Fgi.new(params).values)
        end

        private

        def deep_struct(obj)
          case obj
          when Hash
            OpenStruct.new(obj.transform_values { |v| deep_struct(to_i(v)) })
          when Array
            obj.map { |v| deep_struct(v) }
          else
            to_i(obj)
          end
        end

        def to_i(value)
          value.to_s.match?(/^\d+$/) ? value.to_i : value
        end
      end
    end
  end
end
