# frozen_string_literal: true

module NextGen
  class Base
    class << self
      attr_accessor :app_info
    end

    self.app_info = ::ENV['APP_INFO'] || "#{::NextGen::NAME} V #{::NextGen.version}"
  end
end
