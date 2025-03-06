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
        cryptos.each do |crypto|
          tickers = crypto.tickers
          indicators = Services::IndicatorService.new(tickers).calculate_all

          file_path = data_file_path(crypto)
          data = Models::CryptoMarketData.new(crypto, tickers, indicators).to_h

          save_data(file_path, data)
        end
      end

      private

      def data_file_path(crypto)
        base_path = File.join(Dir.pwd, 'data', Time.now.strftime('%Y-%m-%d %H'))
        file_path = File.join(base_path, "#{crypto.name}.json")

        file_path.sub!('data', 'spec/data') if defined?(RSpec)

        FileUtils.mkdir_p(File.dirname(file_path))

        file_path
      end

      def save_data(file_path, data)
        File.write(file_path, JSON.pretty_generate(data))
      end
    end
  end
end
