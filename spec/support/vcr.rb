# frozen_string_literal: true

require('vcr')

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.default_cassette_options = { record: :new_episodes }
end
