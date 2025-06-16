# frozen_string_literal: true

require 'sentry-ruby'

module Lunaris
  module Config
    class SentryClient
      def self.setup
        return unless defined?(Sentry)

        Sentry.init do |config|
          config.dsn                = ENV.fetch('SENTRY_DSN', nil)
          config.traces_sample_rate = 0.2
          config.environment        = ENV.fetch('APP_ENV', 'development')
          config.send_default_pii   = true
        end
      end
    end
  end
end
