# frozen_string_literal: true

require 'zeitwerk'

module NextGen
  class Autoloader
    class Inflector < ::Zeitwerk::Inflector
      INFLECTIONS_MAP = {
        version: 'VERSION'
      }.freeze

      def camelize(basename, _abspath)
        INFLECTIONS_MAP[basename.to_sym] || super
      end
    end

    class << self
      LIB_PATH = ::File.dirname(__dir__).freeze

      def setup!
        loader = ::Zeitwerk::Loader.new
        loader.tag = 'next_gen'
        loader.inflector = Inflector.new
        loader.push_dir(LIB_PATH)
        loader.collapse(::File.join(LIB_PATH, 'next_gen', 'resources'))

        ignored_paths.each { |path| loader.ignore(path) }

        loader.setup
      end

      private

      def ignored_paths
        [
          ::File.join(LIB_PATH, 'next_gen', 'patches')
        ].freeze
      end
    end
  end
end
