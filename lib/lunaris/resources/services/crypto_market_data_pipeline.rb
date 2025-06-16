# frozen_string_literal: true

module Lunaris
  module Services
    class CryptoMarketDataPipeline
      include Lunaris::Helpers::FileHelper
      include Lunaris::Helpers::Loggable

      attr_reader :crypto, :params

      def initialize(context)
        @crypto = context.crypto
        @params = context.params
        @file_base_path = base_path_hour
      end

      def process
        log_info("Processing crypto #{crypto.name} ...")

        tickers = retrieve_tickers
        indicators = calculate_indicators(tickers)
        export_data(tickers, indicators)

        log_info("Export data for #{crypto.name}")
      end

      private

      def calculate_indicators(tickers)
        indicators = Services::IndicatorService.new(tickers).calculate_all
        log_info("Calculation of indicators for #{crypto.name}: OK")
        indicators
      end

      def export_data(tickers, indicators)
        data = Models::CryptoMarketData.new(crypto, tickers, indicators).to_h
        Repositories::FileStorageRepository.new(@file_base_path, "#{crypto.name}.json").save(data)
      end

      def retrieve_tickers
        tickers = crypto.tickers(params)
        log_info("Found #{tickers.count} tickers for #{crypto.name}")
        tickers
      end
    end
  end
end
