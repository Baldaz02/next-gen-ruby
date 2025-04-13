# frozen_string_literal: true

RSpec.describe NextGen::Jobs::MarketAutomationJob do
  let(:crypto_data) { CSV::Row.new(%w[Name Symbol], %w[Bitcoin BTC]) }
  let(:bitcoin_file_path) { 'spec/data/2025-03-04/00/Bitcoin.json' }
  let(:ethereum_file_path) { 'spec/data/2025-03-04/00/Ethereum.json' }
  let(:logger) { instance_double('NextGen::Config::Logger') }

  before do
    Timecop.freeze(Time.local(2025, 3, 4))
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
      expect(logger).to receive(:info).with('Binance API response for BTCUSDT: HTTP 200')
      expect(logger).to receive(:info).with("MarketAutomationJob completed successfully \n")
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
        expect(logger).to receive(:info).with('Binance API response for ETHUSDT: HTTP 200')
        expect(logger).to receive(:info).with("MarketAutomationJob completed successfully \n")

        params = { interval: '1h', limit: 50, timestamps: { start: 1_740_866_400_000, end: 1_741_046_400_000 } }
        described_class.new(params).perform

        expect(File.exist?(ethereum_file_path)).to be_truthy
        json_data = JSON.parse(File.read(ethereum_file_path))

        market_data_path = 'spec/fixtures/data/ethereum_market_data.json'
        json_fixture_data = JSON.parse(File.read(market_data_path))

        expect(json_data).to eq json_fixture_data
      end
    end

    context 'error' do
      it do
        allow_any_instance_of(NextGen::Jobs::MarketAutomationJob).to receive(:process_crypto).and_raise(StandardError,
                                                                                                        'Test error')
        expect(logger).to receive(:info).with('MarketAutomationJob started with 1 cryptos')
        expect(logger).to receive(:error).with('Error processing: Test error')
        expect(Sentry).to receive(:capture_exception).with(instance_of(StandardError))

        described_class.new.perform
      end
    end
  end
end
