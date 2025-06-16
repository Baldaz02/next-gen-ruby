# frozen_string_literal: true

require_relative 'lunaris/autoloader'

module Lunaris
  NAME = 'Lunaris Ruby'

  @mutex = ::Mutex.new

  class << self
    def app_info=(value)
      ::Lunaris::Base.app_info = value
    end

    def ping
      { status: 200 }
    end

    def version
      VERSION
    end
  end
end

Lunaris::Autoloader.setup!
