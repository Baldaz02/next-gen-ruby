# frozen_string_literal: true

RSpec.describe NextGen::Services::CryptoReportService do
  let(:crypto_data) { CSV::Row.new(%w[Name Symbol], %w[Bitcoin BTC]) }

  before do
    Timecop.freeze(Time.local(2025, 3, 4))
    allow(CSV).to receive(:foreach).and_return([crypto_data])
  end

  context '#call', vcr: true do
    it do
      service_response = JSON.parse(described_class.new.call.first)

      # Crypto data
      expect(service_response['crypto']['name']).to eq 'Bitcoin'
      expect(service_response['crypto']['symbol']).to eq 'BTC'

      # Ticker data
      expect(service_response['data'].size).to eq 50
      first_data = service_response['data'].first
      expect(first_data).to have_key('date')
      expect(first_data).to have_key('open_price')
      expect(first_data).to have_key('close_price')
      expect(first_data).to have_key('high_price')
      expect(first_data).to have_key('low_price')
      expect(first_data).to have_key('volume')
    end
  end
end
