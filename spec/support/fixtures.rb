# frozen_string_literal: true

module FixturesHelper
  def load_fixture(fixture)
    fixture_path = File.expand_path(File.join(__dir__, '..', 'fixtures', fixture))
    File.read(fixture_path)
  end
end

RSpec.configure { |config| config.include(FixturesHelper) }