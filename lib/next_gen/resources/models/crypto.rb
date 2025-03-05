# frozen_string_literal: true

module NextGen
  module Models
    class Crypto
      attr_reader :name, :symbol

      def initialize(params)
        @name, @symbol = params.values_at(:name, :symbol)
      end
    end
  end
end
