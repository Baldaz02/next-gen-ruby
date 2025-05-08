# frozen_string_literal: true

module NextGen
  module Services
    class CryptoMarketDataPipeline
      include NextGen::Helpers::FileHelper
      attr_reader :crypto, :params

      def initialize(context)
        @crypto = context.crypto
        @params = context.params
        @file_base_path = base_path_hour
        @logger = Config::Logger.instance
      end

      def process
        log("Processing crypto #{crypto.name} ...")

        tickers = crypto.tickers(params)
        log("Found #{tickers.count} tickers for #{crypto.name}")

        indicators = Services::IndicatorService.new(tickers).calculate_all
        log("Calculation of indicators for #{crypto.name}: OK")

        data = Models::CryptoMarketData.new(crypto, tickers, indicators).to_h
        Repositories::FileStorageRepository.new(@file_base_path, "#{crypto.name}.json").save(data)

        log("Export data for #{crypto.name}")
      end

      private

      def log(msg)
        @logger.info(msg)
      end
    end
  end
end
