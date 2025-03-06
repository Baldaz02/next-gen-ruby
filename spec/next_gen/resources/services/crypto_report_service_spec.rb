# frozen_string_literal: true

RSpec.describe NextGen::Services::CryptoReportService do
  let(:crypto_data) { CSV::Row.new(%w[Name Symbol], %w[Bitcoin BTC]) }

  before do
    Timecop.freeze(Time.local(2025, 3, 4))
    allow(CSV).to receive(:foreach).and_return([crypto_data])
  end

  context '#call', vcr: true do
    it do
      service = NextGen::Services::CryptoReportService.new
      result = service.call

      file_path = 'spec/data/2025-03-04 00/Bitcoin.json'
      expect(File.exist?(file_path)).to be_truthy
      json_data = JSON.parse(File.read(file_path))

      market_data_path = 'spec/fixtures/data/market_data.json'
      json_fixture_data = JSON.parse(File.read(market_data_path))

      expect(json_data).to eq json_fixture_data
    end
  end
end
