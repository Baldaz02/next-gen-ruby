# frozen_string_literal: true

RSpec.describe NextGen::Config::Application do
  describe '.timestamp_to_date' do
    it do
      timestamp = 1_699_102_800_000 / 1000
      expected_date = Time.new(2023, 11, 4, 14, 0o0, 0o0, '+01:00')

      result = described_class.timestamp_to_date(timestamp)
      expect(result).to eq(expected_date)
    end
  end
end
