# frozen_string_literal: true

module NextGen
  module Helpers
    module FileHelper
      def initialize_time
        @today ||= DateTime.parse(ENV.fetch('DATETIME', nil))
      end

      def base_path_day
        initialize_time
        "data/#{@today.strftime('%Y-%m-%d')}"
      end

      def base_path_hour
        initialize_time
        "#{base_path_day}/#{@today.strftime('%H')}"
      end
    end
  end
end
