# frozen_string_literal: true

RSpec.describe NextGen::Jobs::MarketAutomationJob do
  let(:crypto_data) { CSV::Row.new(%w[Name Symbol], %w[Bitcoin BTC]) }
  let(:file_path) { 'spec/data/2025-03-04/00/Bitcoin.json' }
  let(:logger) { instance_double('NextGen::Config::Logger') }

  before do
    NextGen::Config::Application.set_timezone('GMT')
    Timecop.freeze(Time.local(2025, 3, 4))
    allow(CSV).to receive(:foreach).and_return([crypto_data])

    FileUtils.rm_f(file_path)
    allow(NextGen::Config::Logger).to receive(:instance).and_return(logger)
  end

  context '#perform', vcr: true do
    it do
      expect(logger).to receive(:info).with('MarketAutomationJob started with 1 cryptos')
      expect(logger).to receive(:info).with('MarketAutomationJob completed successfully')
      described_class.new.perform

      expect(File.exist?(file_path)).to be_truthy
      json_data = JSON.parse(File.read(file_path))

      market_data_path = 'spec/fixtures/data/market_data.json'
      json_fixture_data = JSON.parse(File.read(market_data_path))

      expect(json_data).to eq json_fixture_data
    end

    context 'error' do
      it do
        allow_any_instance_of(NextGen::Jobs::MarketAutomationJob).to receive(:process_crypto).and_raise(StandardError,
                                                                                                        'Test error')
        expect(logger).to receive(:info).with('MarketAutomationJob started with 1 cryptos')
        expect(logger).to receive(:error).with('Error processing Bitcoin: Test error')

        described_class.new.perform
      end
    end
  end
end
