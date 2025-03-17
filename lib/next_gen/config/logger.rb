# frozen_string_literal: true

require 'logger'
require 'singleton'
require 'date'

module NextGen
  module Config
    class Logger
      include Singleton
      include NextGen::Helpers::FileHelper

      def initialize
        log_directory = defined?(RSpec) ? 'spec/' : File.expand_path('', Dir.pwd)
        log_file = "#{log_directory}/#{base_path_day}/production.log"
        FileUtils.mkdir_p(File.dirname(log_file))

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
