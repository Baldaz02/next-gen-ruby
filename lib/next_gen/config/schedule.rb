# frozen_string_literal: true

require_relative '../../next_gen'
require 'json'

ENV.fetch('APP_ENV', 'development')
NextGen::Config::SentryClient.setup
NextGen::Config::Application.set_timezone('GMT')

begin
  raw_params = ARGV[0]
  parsed_params = raw_params ? JSON.parse(raw_params, symbolize_names: true) : nil

  if parsed_params&.dig(:timestamps, :end)
    timestamp = parsed_params[:timestamps][:end] / 1000
    datetime = NextGen::Config::Application.timestamp_to_date(timestamp)
    ENV['DATETIME'] = datetime.to_s
  else
    ENV['DATETIME'] = Time.now.to_s
  end

  logger = NextGen::Config::Logger.instance
  logger.info("[#{Time.now}] Schedule MarketAutomationJob ok with params: #{parsed_params.inspect}")
  logger.info("→ ENV['DATETIME'] = #{ENV['DATETIME']}") if ENV['DATETIME']

  NextGen::Jobs::MarketAutomationJob.new(parsed_params).perform
rescue StandardError => e
  logger ||= NextGen::Config::Logger.instance
  logger.error("Error occured: #{e.message}")
  Sentry.capture_exception(e)
  raise e
end
