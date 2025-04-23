# frozen_string_literal: true

require 'sentry-ruby'

RSpec.describe 'schedule.rb' do
  let(:job_instance) { instance_double(NextGen::Jobs::MarketAutomationJob, perform: true) }
  let(:script_path) { File.expand_path('lib/next_gen/config/schedule.rb') }
  let(:logger) { instance_double('NextGen::Config::Logger') }

  before do
    Timecop.freeze(Time.local(2025, 3, 3))
    allow(NextGen::Jobs::MarketAutomationJob).to receive(:new).and_return(job_instance)
  end

  after(:all) do
    ENV.delete('DATETIME')

    base_dir = File.expand_path('../../data', __dir__)
    log_files = Dir.glob("#{base_dir}/**/*.log")
  
    log_files.each do |log_file|
      File.delete(log_file)
  
      current_dir = File.dirname(log_file)
  
      while current_dir.start_with?(base_dir) && Dir.empty?(current_dir)
        Dir.rmdir(current_dir)
        current_dir = File.dirname(current_dir)
      end
    end
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
    before { allow(NextGen::Config::Logger).to receive(:instance).and_return(logger) }

    it do
      invalid_json = '{invalid: json'
      stub_const('ARGV', [invalid_json])

      expect(Sentry).to receive(:capture_exception).with(instance_of(JSON::ParserError)).once
      expect(logger).to receive(:error).with("Error occured: expected object key, got 'invalid: json")
      expect { load script_path }.to raise_error(JSON::ParserError)
    end
  end
end
