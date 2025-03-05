# frozen_string_literal: true

module NextGen
  module Models
    class Ticker
      attr_reader :date, :open_price, :close_price, :high_price, :low_price, :volume, :crypto

      def initialize(candle_params, crypto)
        @date, @open_price, @close_price, @high_price, @low_price, @volume =
          candle_params.values_at(:date, :open_price, :close_price, :high_price, :low_price, :volume)

        @crypto = crypto
      end
    end
  end
end
