# frozen_string_literal: true

module NextGen
  module Models
    class Ticker
      attr_reader :date, :open_price, :close_price, :high_price, :low_price, :volume, :crypto_name

      def initialize(date, open_price, close_price, high_price, low_price, volume, crypto_name)
        @date = date
        @open_price = open_price
        @close_price = close_price
        @high_price = high_price
        @low_price = low_price
        @volume = volume
        @crypto_name = crypto_name
      end
    end
  end
end
