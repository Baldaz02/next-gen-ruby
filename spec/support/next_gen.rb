# frozen_string_literal: true

RSpec.shared_context('NextGen config', shared_context: :metadata) do
  before do
    NextGen::Config::Application.set_timezone('GMT')
    ENV['DATETIME'] = '2025-03-04 00:00:00 +0000'
    ENV['APP_ENV'] = 'test'

    ENV['AWS_ACCESS_KEY_ID'] = 'AWS_ACCESS_KEY_ID'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'AWS_SECRET_ACCESS_KEY'
  end
end

RSpec.configure do |config|
  config.include_context('NextGen config')
end
