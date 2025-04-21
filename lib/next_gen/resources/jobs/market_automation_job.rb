# frozen_string_literal: true

require 'csv'
require 'ostruct'
require 'concurrent'

module NextGen
  module Jobs
    class MarketAutomationJob
      include NextGen::Helpers::FileHelper

      attr_reader :cryptos, :logger, :file_base_path, :futures, :params

      def initialize(params = nil)
        @cryptos = Models::Crypto.all
        @futures = []

        @logger = Config::Logger.instance
        @file_base_path = base_path_hour
        @params = params
      end

      def perform
        logger.info("MarketAutomationJob started with #{@cryptos.size} cryptos")

        @cryptos.each do |crypto|
          futures << Concurrent::Promises.future do
            logger.info("Processing crypto #{crypto.name} ...")
            process_crypto(crypto)
          end
        end

        Concurrent::Promises.zip(*futures).value!
        logger.info('MarketAutomationJob completed successfully')
      end

      private

      def export_data(crypto, tickers, indicators)
        data = Models::CryptoMarketData.new(crypto, tickers, indicators).to_h
        file_repo = Repositories::FileStorageRepository.new(file_base_path, "#{crypto.name}.json")
        file_repo.save(data)
      end

      def process_crypto(crypto)
        tickers = crypto.tickers(params)
        crypto_name = crypto.name
        logger.info("Founded #{tickers.count} tickers for #{crypto_name}")

        indicators = Services::IndicatorService.new(tickers).calculate_all
        logger.info("Calculation of indicators for #{crypto_name}: OK")

        export_data(crypto, tickers, indicators)
        logger.info("Export data for #{crypto.name}")
      end
    end
  end
end
