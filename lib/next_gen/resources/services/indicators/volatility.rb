# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class Volatility < BaseIndicatorService
        OPTIONS = {
          bb: { period: 20, price_key: :close },
          atr: {},
          kc: {}
        }.freeze
      end
    end
  end
end
