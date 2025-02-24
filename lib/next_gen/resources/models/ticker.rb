# frozen_string_literal: true

module NextGen
  module Models
    class Ticker
      attr_reader :date, :open_price, :close_price, :high_price, :low_price, :volume, :crypto_name

      def initialize(candle_params, crypto_name)
        @date, @open_price, @close_price, @high_price, @low_price, @volume =
          candle_params.values_at(:date, :open_price, :close_price, :high_price, :low_price, :volume)

        @crypto_name = crypto_name
      end
    end
  end
end
