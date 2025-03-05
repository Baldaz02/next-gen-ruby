# frozen_string_literal: true

require 'csv'
require 'ostruct'

module NextGen
  module Services
    class CryptoReportService
      attr_reader :cryptos

      def initialize
        @cryptos = Models::Crypto.all
      end

      def call
        json = []
        cryptos.each do |crypto|
          tickers = crypto.tickers
          indicators = Services::IndicatorService.new(tickers).calculate_all
          json << Models::CryptoMarketData.new(crypto, tickers, indicators).to_json
        end

        json
      end
    end
  end
end
