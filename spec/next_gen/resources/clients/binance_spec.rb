# frozen_string_literal: true

RSpec.describe NextGen::Clients::Binance do
  let(:params) do
    { symbol: 'BTCUSDT', interval: '1m', timestamps: { start: 1_699_102_800_000, end: 1_699_106_400_000 } }
  end

  let(:client) { described_class.new(OpenStruct.new(params)) }

  let(:expected_date) { Time.at(1_699_102_800_000 / 1000) }

  let(:candle) do
    {
      unix_timestamp: 1_699_102_800_000, date: expected_date, close_price: 34_756.01,
      high_price: 34_758.78, low_price: 34_756.0, open_price: 34_758.78, volume: 7.53895
    }
  end

  before do
    Timecop.freeze(Time.local(2025, 3, 4))
  end

  context '#candlestick', vcr: true do
    context 'params not all present' do
      it do
        response = client.candlestick
        expect(response).to be_an(Array)
        expect(response).not_to be_empty

        first_candle = response.first
        expect(first_candle).to eq candle
      end
    end

    context 'all params present' do
      it do
        params[:limit] = 10

        response = client.candlestick
        expect(response).to be_an(Array)
        expect(response).not_to be_empty

        first_candle = response.first
        expect(first_candle).to eq candle
      end
    end
  end
end
