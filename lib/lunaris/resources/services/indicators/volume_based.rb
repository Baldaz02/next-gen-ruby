# frozen_string_literal: true

module Lunaris
  module Services
    module Indicators
      class VolumeBased < BaseIndicatorService
        OPTIONS = {
          obv: { period: 20, price_key: :close },
          cmf: { period: 20 },
          vwap: {}
        }.freeze
      end
    end
  end
end
