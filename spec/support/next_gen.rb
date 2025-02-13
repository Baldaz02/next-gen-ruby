# frozen_string_literal: true

RSpec.shared_context('NextGen config', shared_context: :metadata) do
end

RSpec.configure do |config|
  config.include_context('NextGen config')
end
