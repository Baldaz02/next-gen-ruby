# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'fileutils'

module NextGen
  module Clients
    class Fgi
      BASE_URL = 'https://api.alternative.me/fng/'

      attr_accessor :params
      attr_reader :today

      def initialize(params)
        @params = params
        @today = Date.today
      end

      def values
        datetime = DateTime.parse(ENV.fetch('DATETIME', nil))
        params[:limit] = 10000 if datetime.to_date < today
        base_path = "data/#{datetime.strftime('%Y-%m-%d')}"

        file_repo = Repositories::FileStorageRepository.new(base_path, 'fgi.json')
        data = file_repo.load
        return data if data

        response = RestClient.get(BASE_URL, params: { limit: params[:limit] })
        json_data = JSON.parse(response.body)['data']
        file_repo.save(json_data)
        json_data
      end
    end
  end
end
