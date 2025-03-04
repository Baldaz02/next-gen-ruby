# frozen_string_literal: true

module NextGen
  module Services
    module Indicators
      class TrendFollowing < BaseIndicatorService
        OPTIONS = {
          sma: { 'sma10' => { period: 10, price_key: :close }, 'sma20' => { period: 20, price_key: :close } },
          ema: { 'ema10' => { period: 10, price_key: :close }, 'ema20' => { period: 20, price_key: :close } },
          macd: { fast_period: 12, slow_period: 26, signal_period: 9, price_key: :close }
        }.freeze
      end
    end
  end
end
