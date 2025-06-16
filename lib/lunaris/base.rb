# frozen_string_literal: true

module Lunaris
  class Base
    class << self
      attr_accessor :app_info
    end

    self.app_info = ::ENV['APP_INFO'] || "#{::Lunaris::NAME} V #{::Lunaris.version}"
  end
end
