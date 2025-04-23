# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'fileutils'

module NextGen
  module Clients
    class Fgi
      attr_accessor :params
      attr_reader :client, :today

      def initialize(params)
        @params = params
        @client = Clients::Aws.new
        @today = Date.today
      end

      def values
        datetime = DateTime.parse(ENV.fetch('DATETIME', nil))
        params[:limit] = 10_000 if datetime.to_date < today
        base_path = "data/#{datetime.strftime('%Y-%m-%d')}"

        file_repo = Repositories::FileStorageRepository.new(base_path, 'fgi.json')
        data = file_repo.load
        return data if data

        lambda_params = { lambda: { class: 'Clients::Fgi', method: 'values' } }
        response = client.invoke({
                                   function_name: 'NextGen',
                                   invocation_type: 'RequestResponse',
                                   log_type: 'Tail',
                                   payload: JSON.generate(lambda_params.merge(params))
                                 })

        json_data = JSON.parse(response.payload.string)['body']
        file_repo.save(json_data)
        json_data
      end
    end
  end
end
