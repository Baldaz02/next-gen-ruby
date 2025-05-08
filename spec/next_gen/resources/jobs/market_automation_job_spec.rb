# frozen_string_literal: true

require 'aws-sdk-lambda'

RSpec.describe NextGen::Jobs::MarketAutomationJob do
  let(:crypto_data) { CSV::Row.new(%w[Name Symbol], %w[Bitcoin BTC]) }
  let(:bitcoin_file_path) { 'spec/data/2025-03-04/00/Bitcoin.json' }
  let(:ethereum_file_path) { 'spec/data/2025-03-04/00/Ethereum.json' }
  let(:logger) { instance_double('NextGen::Config::Logger') }

  before do
    allow(CSV).to receive(:foreach).and_return([crypto_data])

    FileUtils.rm_f(bitcoin_file_path)
    allow(NextGen::Config::Logger).to receive(:instance).and_return(logger)
  end

  after do
    FileUtils.rm_f(bitcoin_file_path)
    FileUtils.rm_f(ethereum_file_path)
  end

  context '#perform', vcr: true do
    it do
      expect(logger).to receive(:info).with('MarketAutomationJob started with 1 cryptos')
      expect(logger).to receive(:info).with('Processing crypto Bitcoin ...')
      expect(logger).to receive(:info).with(
        'Lambda call with params: {:lambda=>{:class=>"Clients::Binance", :method=>"candlestick"}, ' \
        ':interval=>"1h", :limit=>50, :symbol=>"BTCUSDT"} - status: 200'
      )
      expect(logger).to receive(:info).with('Found 50 tickers for Bitcoin')
      expect(logger).to receive(:info).with('Calculation of indicators for Bitcoin: OK')
      expect(logger).to receive(:info).with('Export data for Bitcoin')
      expect(logger).to receive(:info).with('MarketAutomationJob completed successfully')

      described_class.new.perform

      expect(File.exist?(bitcoin_file_path)).to be_truthy
      json_data = JSON.parse(File.read(bitcoin_file_path))

      market_data_path = 'spec/fixtures/data/market_data.json'
      json_fixture_data = JSON.parse(File.read(market_data_path))

      expect(json_data).to eq json_fixture_data
    end

    context 'with params' do
      before do
        allow(CSV).to receive(:foreach).and_return([CSV::Row.new(%w[Name Symbol], %w[Ethereum ETH])])
      end

      it do
        expect(logger).to receive(:info).with('MarketAutomationJob started with 1 cryptos')
        expect(logger).to receive(:info).with('Processing crypto Ethereum ...')
        expect(logger).to receive(:info).with(
          'Lambda call with params: {:lambda=>{:class=>"Clients::Binance", :method=>"candlestick"}, ' \
          ':interval=>"1h", :limit=>50, :timestamps=>{:start=>1740866400000, :end=>1741046400000}, ' \
          ':symbol=>"ETHUSDT"} - status: 200'
        )
        expect(logger).to receive(:info).with('Found 50 tickers for Ethereum')
        expect(logger).to receive(:info).with('Calculation of indicators for Ethereum: OK')
        expect(logger).to receive(:info).with('Export data for Ethereum')
        expect(logger).to receive(:info).with('MarketAutomationJob completed successfully')

        params = { interval: '1h', limit: 50, timestamps: { start: 1_740_866_400_000, end: 1_741_046_400_000 } }
        described_class.new(params).perform

        expect(File.exist?(ethereum_file_path)).to be_truthy
        json_data = JSON.parse(File.read(ethereum_file_path))

        market_data_path = 'spec/fixtures/data/ethereum_market_data.json'
        json_fixture_data = JSON.parse(File.read(market_data_path))

        expect(json_data).to eq json_fixture_data
      end
    end
  end
end
