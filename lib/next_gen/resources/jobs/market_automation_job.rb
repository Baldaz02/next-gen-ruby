# frozen_string_literal: true

require 'csv'
require 'ostruct'
require 'concurrent'

module NextGen
  module Jobs
    class MarketAutomationJob
      include NextGen::Helpers::FileHelper

      attr_reader :cryptos, :logger, :file_base_path, :futures

      def initialize
        @cryptos = Models::Crypto.all
        Config::Application.set_timezone('GMT')

        @futures = []
        @logger = Config::Logger.instance
        @file_base_path = base_path_hour
      end

      def perform
        logger.info("MarketAutomationJob started with #{@cryptos.size} cryptos")

        @cryptos.each do |crypto|
          futures << Concurrent::Promises.future do
            process_crypto(crypto)
        end

        Concurrent::Promises.zip(*futures).value!
        logger.info("MarketAutomationJob completed successfully")

        rescue => e
          logger.error("Error processing #{crypto.name}: #{e.message}")
        end
      end

      private

      def export_data(crypto, tickers, indicators)
        data = Models::CryptoMarketData.new(crypto, tickers, indicators).to_h
        file_repo = Repositories::FileStorageRepository.new(file_base_path, "#{crypto.name}.json")
        file_repo.save(data)
      end

      def process_crypto(crypto)
        tickers = crypto.tickers
        indicators = Services::IndicatorService.new(tickers).calculate_all
        export_data(crypto, tickers, indicators)
      end
    end
  end
end
