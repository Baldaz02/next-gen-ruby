# frozen_string_literal: true

require 'sentry-ruby'

module NextGen
  module Config
    class SentryClient
      def self.setup
        return unless defined?(Sentry)

        Sentry.init do |config|
          config.dsn                = ENV['SENTRY_DSN']
          config.traces_sample_rate = 0.2
          config.environment        = ENV['APP_ENV'] || 'development'
          config.send_default_pii   = true
        end
      end
    end
  end
end
