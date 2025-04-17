# frozen_string_literal: true

require 'aws-sdk-lambda'

module NextGen
  module Clients
    class Aws
      def initialize
        @client = ::Aws::Lambda::Client.new(
          access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
          secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
          region: ENV.fetch('AWS_REGION', 'eu-west-2')
        )
      end

      def invoke(params)
        @client.invoke(params)
      end
    end
  end
end