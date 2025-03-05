# frozen_string_literal: true

RSpec.describe NextGen::Services::CryptoReportService do
  before { Timecop.freeze(Time.local(2025, 3, 4)) }

  let(:crypto_data) { CSV::Row.new(%w[Name Symbol], %w[Bitcoin BTC]) }
  let(:binance_client) { instance_double('NextGen::Clients::Binance') }
  let(:indicator_service) { instance_double('NextGen::Services::IndicatorService', calculate_all: true) }
  let(:candlestick_data) { [{ open: 50_000, high: 51_000, low: 49_500, close: 50_500 }] }

  before do
    allow(CSV).to receive(:foreach).and_return([crypto_data])
    allow(NextGen::Clients::Binance).to receive(:new).and_return(binance_client)
    allow(binance_client).to receive(:candlestick).and_return(candlestick_data)
    allow(NextGen::Services::IndicatorService).to receive(:new).and_return(indicator_service)
  end

  it do
    expect(NextGen::Clients::Binance).to receive(:new).with(
      have_attributes(symbol: 'BTCUSDT', interval: '1h', limit: 50)
    ).and_return(binance_client)

    expect(NextGen::Services::IndicatorService).to receive(:new).with(kind_of(Array)).and_return(indicator_service)
    expect(indicator_service).to receive(:calculate_all)

    expect { described_class.new.call }.not_to raise_error
  end
end
