# frozen_string_literal: true

module Lunaris
  module Controllers
    class MarketAutomationController
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def execute_job
        Jobs::MarketAutomationJob.new(data).perform
      end
    end
  end
end
