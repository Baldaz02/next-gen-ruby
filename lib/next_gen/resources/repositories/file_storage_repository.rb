# frozen_string_literal: true

require 'json'
require 'fileutils'

module NextGen
  module Repositories
    class FileStorageRepository
      attr_reader :base_directory, :file_name

      def initialize(base_directory, file_name)
        @base_directory = File.join(Dir.pwd, base_directory)
        @file_name = File.join(@base_directory, file_name)
        @file_name.sub!('data', 'spec/data') if defined?(RSpec)
      end

      def save(data)
        FileUtils.mkdir_p(File.dirname(file_name))
        File.write(file_name, to_json(data))
      end

      def load
        return JSON.parse(File.read(file_name)) if File.exist?(file_name)

        nil
      end

      private

      def to_json(data)
        JSON.pretty_generate(data)
      end
    end
  end
end
