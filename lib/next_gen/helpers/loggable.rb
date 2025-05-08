# frozen_string_literal: true

module NextGen
  module Helpers
    module Loggable
      def logger
        @logger ||= Config::Logger.instance
      end

      def log_info(message)
        logger.info(message)
      end
    end
  end
end
