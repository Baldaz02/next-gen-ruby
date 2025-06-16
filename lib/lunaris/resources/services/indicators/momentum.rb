# frozen_string_literal: true

module Lunaris
  module Services
    module Indicators
      class Momentum < BaseIndicatorService
        OPTIONS = {
          rsi: { period: 14, price_key: :close },
          sr: {},
          tsi: { low_period: 13, high_period: 25, price_key: :close }
        }.freeze
      end
    end
  end
end
