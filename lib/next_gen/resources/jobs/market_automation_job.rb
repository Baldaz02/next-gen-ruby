# frozen_string_literal: true

require 'csv'
require 'ostruct'
require 'concurrent'

module NextGen
  module Jobs
    class MarketAutomationJob
      attr_reader :cryptos, :file_base_path, :futures

      def initialize
        @cryptos = Models::Crypto.all
        Config::Application.set_timezone('GMT')

        @file_base_path = "data/#{Time.now.strftime('%Y-%m-%d %H')}"
        @futures = []
      end

      def perform
        @cryptos.each do |crypto|
          futures << Concurrent::Promises.future do
            process_crypto(crypto)
          end
        end

        Concurrent::Promises.zip(*futures).value!
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
