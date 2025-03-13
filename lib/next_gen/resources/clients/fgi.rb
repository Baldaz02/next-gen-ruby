# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'fileutils'

module NextGen
  module Clients
    class Fgi
      BASE_URL = 'https://api.alternative.me/fng/'

      attr_reader :params

      def initialize(params)
        @params = params
      end

      def values
        base_path = "data/#{Time.now.strftime('%Y-%m-%d')}"
        file_repo = Repositories::FileStorageRepository.new(base_path, 'fgi.json')

        if (data = file_repo.load)
          data
        else
          response = RestClient.get(BASE_URL, { params: { limit: params[:limit] } })
          json_data = JSON.parse(response.body)['data']
          file_repo.save(json_data)
          json_data
        end
      end
    end
  end
end
