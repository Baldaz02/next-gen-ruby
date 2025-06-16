# frozen_string_literal: true

module Lunaris
  class Endpoint
    attr_reader :logger, :params

    def initialize(params)
      ENV.fetch('APP_ENV', 'development')
      Config::Application.set_timezone('GMT')
      Config::SentryClient.setup

      @params = params
      set_datetime
      @logger = Config::Logger.instance
    end

    def call
      data = params[:data]
      controller = Object.const_get(params[:controller_name]).new(data)
      controller.send(params[:action_name])
    rescue StandardError => e
      logger.error("Error occured: #{e.message}")
      Sentry.capture_exception(e)
      raise e
    end

    private

    def set_datetime
      if params&.dig(:data, :timestamps, :end)
        timestamp = params.dig(:data, :timestamps, :end) / 1000
        datetime = Config::Application.timestamp_to_date(timestamp)
        ENV['DATETIME'] = datetime.to_s
      else
        ENV['DATETIME'] = Time.now.to_s
      end
    end
  end
end
