# frozen_string_literal: true

require 'aws-sdk-lambda'

RSpec.describe NextGen::Clients::Binance do
  let(:params) do
    { symbol: 'BTCUSDT', interval: '1m', timestamps: { start: 1_699_102_800_000, end: 1_699_106_400_000 } }
  end

  let(:client) { described_class.new(params) }
  let(:candles) do
    [
      {
        unix_timestamp: 1_699_102_800_000.0,
        open_price: 34_758.78,
        high_price: 34_758.78,
        low_price: 34_756.0,
        close_price: 34_756.01,
        volume: 7.53895,
        date: '2023-11-04 13:00:00 +0000'
      }
    ]
  end

  let(:response_payload) do
    StringIO.new(JSON.generate({ statusCode: 200, body: candles }))
  end

  let(:mock_response) do
    instance_double(Aws::Lambda::Types::InvocationResponse, payload: response_payload)
  end

  before do
    allow(Aws::Lambda::Client).to receive(:new).and_return(instance_double(Aws::Lambda::Client, invoke: mock_response))
  end

  context '#candlestick' do
    context 'params not all present' do
      it do
        expected_candle = candles.map { |c| c.transform_keys(&:to_s) }.first
        response = client.candlestick

        expect(response).to be_an(Array)
        expect(response.first).to eq expected_candle
      end
    end

    context 'all params present' do
      it do
        params[:limit] = 10
        expected_candle = candles.map { |c| c.transform_keys(&:to_s) }.first
        response = client.candlestick

        expect(response).to be_an(Array)
        expect(response.first).to eq expected_candle
      end
    end
  end
end
