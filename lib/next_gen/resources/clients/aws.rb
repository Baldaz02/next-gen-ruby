# frozen_string_literal: true

require 'aws-sdk-lambda'

module NextGen
  module Clients
    class Aws
      include NextGen::Helpers::Loggable

      attr_reader :client

      def initialize
        @client = ::Aws::Lambda::Client.new(
          access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
          secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
          region: ENV.fetch('AWS_REGION', 'eu-west-2')
        )
      end

      def invoke(params)
        response = client.invoke({
                                   function_name: 'NextGen',
                                   invocation_type: 'RequestResponse',
                                   log_type: 'Tail',
                                   payload: JSON.generate(params)
                                 })

        payload = JSON.parse(response.payload.string)
        log_info("Lambda call with params: #{params} - status: #{payload['statusCode']}")
        payload['body']
      end
    end
  end
end
