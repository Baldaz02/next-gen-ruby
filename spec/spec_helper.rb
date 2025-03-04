# frozen_string_literal: true

require('byebug')
require('simplecov')
require('ostruct')
require('timecop')
require('webmock/rspec')

SimpleCov.start do
  minimum_coverage(100)
  add_filter('/spec/')
end

require('next_gen')

# Requires supporting ruby files
Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |file| require(file) }

RSpec.configure do |config|
  config.expect_with(:rspec) do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.max_formatted_output_length = 250_000
  end

  config.mock_with(:rspec) do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!

  config.example_status_persistence_file_path = 'tmp/rspec-examples.txt'
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.filter_run_when_matching(:focus)

  config.silence_filter_announcements = true
  config.fail_if_no_examples = true
  config.warnings = false
  config.raise_on_warning = true
  config.threadsafe = true

  config.profile_examples = 10
  config.order = :random
  Kernel.srand(config.seed)
end

WebMock.disable_net_connect!(allow_localhost: true)
