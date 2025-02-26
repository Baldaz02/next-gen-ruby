# frozen_string_literal: true

require 'technical-analysis'

module NextGen
  module Models
    class Indicator
      def self.calculate(type, period, cache_data, options: nil)
        indicator_class = Object.const_get("TechnicalAnalysis::#{type}")

        if %i[Obv Vwap Adi].include?(type)
          indicator_class.calculate(cache_data[period])
        elsif options
          indicator_class.calculate(cache_data[period], options)
        else
          indicator_class.calculate(cache_data[period], period: period, price_key: :close)
        end
      end
    end
  end
end
