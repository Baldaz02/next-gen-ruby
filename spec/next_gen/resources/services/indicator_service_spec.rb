# frozen_string_literal: true

require 'csv'

RSpec.describe NextGen::Services::IndicatorService do
  let(:csv_file) { 'spec/fixtures/data/tickers.csv' }

  let(:tickers) do
    CSV.read(csv_file, headers: true).map do |entry|
      NextGen::Models::Ticker.new(
        entry['Date'],
        entry['Open Price'].to_f,
        entry['Close Price'].to_f,
        entry['High Price'].to_f,
        entry['Low Price'].to_f,
        entry['Volume'].to_f,
        entry['Crypto Name']
      )
    end
  end

  let(:expected_timestamp) { Time.at(1_740_384_000) }

  context 'Simple Moving Averages (SMA)' do
    it do
      sma_data = described_class.new(tickers).simple_moving_averages
      expect(sma_data.count).to eq 2

      sma_10_result = sma_data['sma10']
      expect(sma_10_result.count).to eq 6
      expect(Time.parse(sma_10_result.first.date_time)).to eq expected_timestamp
      expect(sma_10_result.first.sma).to eq 95_800.08700000001

      sma_20_result = sma_data['sma20']
      expect(sma_20_result.count).to eq 6
      expect(Time.parse(sma_20_result.first.date_time)).to eq expected_timestamp
      expect(sma_20_result.first.sma).to eq 95_745.1125
    end
  end

  context 'Exponential Moving Averages (EMA)' do
    it do
      ema_data = described_class.new(tickers).exponential_moving_averages
      expect(ema_data.count).to eq 2

      ema_10_result = ema_data['ema10']
      expect(ema_10_result.count).to eq 6
      expect(Time.parse(ema_10_result.first.date_time)).to eq expected_timestamp
      expect(ema_10_result.first.ema).to eq 95_736.22029778144

      ema_20_result = ema_data['ema20']
      expect(ema_20_result.count).to eq 6
      expect(Time.parse(ema_20_result.first.date_time)).to eq expected_timestamp
      expect(ema_20_result.first.ema).to eq 95_785.91814626193
    end
  end

  context 'Relative Strength Index (RSI)' do
    it do
      rsi_data = described_class.new(tickers).relative_strength_index
      expect(rsi_data.count).to eq 5

      first_rsi = rsi_data.first
      expect(Time.parse(first_rsi.date_time)).to eq expected_timestamp
      expect(first_rsi.rsi).to eq 47.37161756129789
    end
  end
end
