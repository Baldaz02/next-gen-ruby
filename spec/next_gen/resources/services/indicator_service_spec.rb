# frozen_string_literal: true

require 'csv'

RSpec.describe NextGen::Services::IndicatorService do
  let(:csv_file) { 'spec/fixtures/data/tickers.csv' }

  let(:tickers) do
    CSV.read(csv_file, headers: true).map do |entry|
      candle_params = {
        date: entry['Date'],
        open_price: entry['Open Price'].to_f,
        close_price: entry['Close Price'].to_f,
        high_price: entry['High Price'].to_f,
        low_price: entry['Low Price'].to_f,
        volume: entry['Volume'].to_f
      }

      NextGen::Models::Ticker.new(candle_params, entry['Crypto Name'])
    end
  end

  let(:expected_timestamp) { Time.at(1_740_384_000) }

  context 'Trend Following (SMA, EMA, MACD)' do
    it do
      data = described_class.new(tickers).trend_following

      # SMA
      expect(data.sma_values.sma10.count).to eq 6
      sma_10_result = data.sma_values.sma10.first
      expect(Time.parse(sma_10_result.date_time)).to eq expected_timestamp
      expect(sma_10_result.sma).to eq 95_800.08700000001

      expect(data.sma_values.sma20.count).to eq 6
      sma_20_result = data.sma_values.sma20.first
      expect(Time.parse(sma_20_result.date_time)).to eq expected_timestamp
      expect(sma_20_result.sma).to eq 95_745.1125

      # EMA
      expect(data.ema_values.ema10.count).to eq 6
      ema_10_result = data.ema_values.ema10.first
      expect(Time.parse(ema_10_result.date_time)).to eq expected_timestamp
      expect(ema_10_result.ema).to eq 95_736.22029778144

      expect(data.ema_values.ema20.count).to eq 6
      ema_20_result = data.ema_values.ema20.first
      expect(Time.parse(ema_20_result.date_time)).to eq expected_timestamp
      expect(ema_20_result.ema).to eq 95_785.91814626193

      # MACD
      expect(data.macd_values.count).to eq 6
      first_macd = data.macd_values.first
      expect(Time.parse(first_macd.date_time)).to eq expected_timestamp
      expect(first_macd.macd_line).to eq(-178.1478434993478)
      expect(first_macd.macd_histogram).to eq 31.282820089225936
      expect(first_macd.signal_line).to eq(-209.43066358857374)
    end
  end

  context 'Momentum (RSI, SR, TSI)' do
    it do
      data = described_class.new(tickers).momentum

      # RSI
      expect(data.rsi_values.count).to eq 5
      first_rsi = data.rsi_values.first
      expect(Time.parse(first_rsi.date_time)).to eq expected_timestamp
      expect(first_rsi.rsi).to eq 47.37161756129789

      # SR
      expect(data.sr_values.count).to eq 4
      first_sr = data.sr_values.first
      expect(Time.parse(first_sr.date_time)).to eq expected_timestamp
      expect(first_sr.sr).to eq 29.676017412218346
      expect(first_sr.sr_signal).to eq 46.93657011183882

      # TSI
      expect(data.tsi_values.count).to eq 6
      first_tsi = data.tsi_values.first
      expect(Time.parse(first_tsi.date_time)).to eq expected_timestamp
      expect(first_tsi.tsi).to eq -8.000203271189148
    end
  end
end
