# frozen_string_literal: true

require 'technical-analysis'

module NextGen
  module Models
    class Indicator
      def self.calculate(type, period, cache_data, options: nil)
        indicator_class = Object.const_get("TechnicalAnalysis::#{type}")

        if type == :Obv || type == :Vwap || type == :Adi
          indicator_class.calculate(cache_data[period])
        else
          if options
            indicator_class.calculate(cache_data[period], options)
          else
            indicator_class.calculate(cache_data[period], period: period, price_key: :close)
          end
        end
      end
    end
  end
end
