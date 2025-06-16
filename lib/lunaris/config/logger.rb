# frozen_string_literal: true

require 'logger'
require 'singleton'
require 'date'

module Lunaris
  module Config
    class Logger
      include Singleton
      include Lunaris::Helpers::FileHelper

      def initialize
        log_directory = defined?(RSpec) ? 'spec' : File.expand_path('', Dir.pwd)
        log_file = "#{log_directory}/#{base_path_hour}/#{file_name}"
        FileUtils.mkdir_p(File.dirname(log_file))

        @logger = ::Logger.new(log_file)
        @logger.level = ::Logger::DEBUG
      end

      def info(message)
        @logger.info(message)
      end

      def error(message)
        @logger.error(message)
      end

      private

      def file_name
        env = ENV['APP_ENV'] || 'development'

        "#{env}.log"
      end
    end
  end
end
