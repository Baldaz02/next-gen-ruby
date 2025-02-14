# frozen_string_literal: true

RSpec.describe NextGen::Clients::Binance do
  let(:params) do
    { symbol: 'BTCUSDT', interval: '1m', timestamps: { start: 1_699_102_800_000, end: 1_699_106_400_000 } }
  end

  let(:client) { described_class.new(OpenStruct.new(params)) }

  context '#candlestick', vcr: true do
    context 'params not all present' do
      it do
        response = client.candlestick
        expect(response).to be_an(Array)
        expect(response).not_to be_empty

        first_candle = response.first
        expected_date = Time.at(1_699_102_800_000 / 1000)
        expect(first_candle).to eq({ unix_timestamp: 1_699_102_800_000, price: 34_758.78000000, date: expected_date })
      end
    end

    context 'all params present' do
      it do
        params[:limit] = 10

        response = client.candlestick
        expect(response).to be_an(Array)
        expect(response).not_to be_empty

        first_candle = response.first
        expected_date = Time.at(1_699_102_800_000 / 1000)
        expect(first_candle).to eq({ unix_timestamp: 1_699_102_800_000, price: 34_758.78000000, date: expected_date })
      end
    end
  end
end
