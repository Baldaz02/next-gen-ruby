# frozen_string_literal: true

require 'logger'
require 'singleton'
require 'date'

module NextGen
  module Config
    class Logger
      include Singleton

      def initialize
        log_directory = defined?(RSpec) ? 'spec/data/log' : 'data/log'
        log_file = "#{log_directory}/#{Date.today.strftime('%Y-%m-%d')}.log"
        FileUtils.mkdir_p(log_directory)

        @logger = ::Logger.new(log_file, 'daily')
        @logger.level = ::Logger::DEBUG
      end

      def info(message)
        @logger.info(message)
      end

      def error(message)
        @logger.error(message)
      end
    end
  end
end
