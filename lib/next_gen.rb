# frozen_string_literal: true

require_relative './next_gen/autoloader'

module NextGen
  NAME = 'NextGen Ruby'

  @mutex = ::Mutex.new

  class << self
    def app_info=(value)
      ::NextGen::Base.app_info = value
    end

    def ping
      { status: 200 }
    end

    def version
      VERSION
    end
  end
end

::NextGen::Autoloader.setup!