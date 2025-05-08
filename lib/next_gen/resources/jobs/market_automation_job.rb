# frozen_string_literal: true

require 'ostruct'

module NextGen
  module Jobs
    class MarketAutomationJob
      include NextGen::Helpers::Loggable

      attr_reader :params

      def initialize(params = nil)
        @params = params
        @logger = Config::Logger.instance
      end

      def perform
        cryptos = Models::Crypto.all
        log_info("MarketAutomationJob started with #{cryptos.size} cryptos")

        futures = create_pipelines(cryptos)
        Concurrent::Promises.zip(*futures).value!

        log_info('MarketAutomationJob completed successfully')
      end

      private

      def create_pipelines(cryptos)
        cryptos.map do |crypto|
          Concurrent::Promises.future do
            context = OpenStruct.new(crypto: crypto, params: params)
            Services::CryptoMarketDataPipeline.new(context).process
          end
        end
      end
    end
  end
end
