# frozen_string_literal: true

RSpec.describe NextGen::Services::CryptoReportService do
  let(:crypto_data) { CSV::Row.new(%w[Name Symbol], %w[Bitcoin BTC]) }
  let(:file_path) { 'spec/data/2025-03-04 00/Bitcoin.json' }

  before do
    NextGen::Config::Application.set_timezone('GMT')
    Timecop.freeze(Time.local(2025, 3, 4))
    allow(CSV).to receive(:foreach).and_return([crypto_data])

    FileUtils.rm_f(file_path)
  end

  context '#call', vcr: true do
    it do
      service = NextGen::Services::CryptoReportService.new
      service.call

      expect(File.exist?(file_path)).to be_truthy
      json_data = JSON.parse(File.read(file_path))

      market_data_path = 'spec/fixtures/data/market_data.json'
      json_fixture_data = JSON.parse(File.read(market_data_path))

      expect(json_data).to eq json_fixture_data
    end
  end
end
