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
        file_path = data_file_path

        if File.exist?(file_path)
          JSON.parse(File.read(file_path))
        else
          response = RestClient.get(BASE_URL, { params: { limit: params[:limit] } })
          json_data = JSON.parse(response.body)
          save_data(file_path, json_data)
          json_data
        end
      end

      private

      def data_file_path
        base_path = File.join(Dir.pwd, 'data', Time.now.strftime('%Y-%m-%d'))
        file_path = File.join(base_path, 'fgi.json')

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
