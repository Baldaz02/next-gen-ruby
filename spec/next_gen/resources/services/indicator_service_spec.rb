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

  context 'sma' do
    it do
      sma = described_class.new(tickers).simple_moving_averages
      date_time = Time.at(1_740_384_000)

      first_sma = sma['sma10']
      expect(Time.parse(first_sma.date_time)).to eq date_time
      expect(first_sma.sma).to eq 95_800.08700000001

      second_sma = sma['sma20']
      expect(Time.parse(second_sma.date_time)).to eq date_time
      expect(second_sma.sma).to eq 95_745.1125
    end
  end
end
