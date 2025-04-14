# frozen_string_literal: true

require 'sentry-ruby'

RSpec.describe 'schedule.rb' do
  let(:job_instance) { instance_double(NextGen::Jobs::MarketAutomationJob, perform: true) }
  let(:script_path) { File.expand_path('lib/next_gen/config/schedule.rb') }

  before do
    Timecop.freeze(Time.local(2025, 3, 3))
    allow(NextGen::Jobs::MarketAutomationJob).to receive(:new).and_return(job_instance)
  end

  after do
    ENV.delete('DATETIME')
  end

  context 'without params' do
    it do
      stub_const('ARGV', [])
      load script_path
      expect(ENV.fetch('DATETIME', nil)).to eq '2025-03-03 00:00:00 +0000'
    end
  end

  context 'with valid params containing timestamps' do
    let(:params) do
      {
        interval: '1h',
        limit: 50,
        timestamps: {
          start: 1_740_866_400_000,
          end: 1_741_046_400_000
        }
      }.to_json
    end

    it do
      stub_const('ARGV', [params])
      load script_path

      expected_datetime = '2025-03-04 00:00:00 +0000'
      expect(ENV.fetch('DATETIME', nil)).to eq expected_datetime
    end
  end

  context 'with params missing timestamps' do
    let(:params) do
      {
        interval: '1h',
        limit: 50
      }.to_json
    end

    it do
      stub_const('ARGV', [params])
      load script_path
      expect(ENV.fetch('DATETIME', nil)).to eq '2025-03-03 00:00:00 +0000'
    end
  end

  context 'invalid json' do
    it do
      invalid_json = '{invalid: json'
      stub_const('ARGV', [invalid_json])

      expect(Sentry).to receive(:capture_exception).with(instance_of(JSON::ParserError)).once
      expect { load script_path }.to raise_error(JSON::ParserError)
    end
  end
end
