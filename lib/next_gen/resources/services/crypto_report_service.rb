# frozen_string_literal: true

require 'csv'
require 'ostruct'

module NextGen
  module Services
    class CryptoReportService
      attr_reader :cryptos

      def initialize
        @cryptos = Models::Crypto.all
        Config::Application.set_timezone('GMT')
      end

      def call
        base_path = "data/#{Time.now.strftime('%Y-%m-%d %H')}"

        cryptos.each do |crypto|
          tickers = crypto.tickers
          indicators = Services::IndicatorService.new(tickers).calculate_all

          data = Models::CryptoMarketData.new(crypto, tickers, indicators).to_h
          file_repo = Repositories::FileStorageRepository.new(base_path, "#{crypto.name}.json")
          file_repo.save(data)
        end
      end
    end
  end
end
