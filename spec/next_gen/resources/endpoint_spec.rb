# frozen_string_literal: true

require 'sentry-ruby'

RSpec.describe NextGen::Endpoint do
  let(:logger) { instance_double('NextGen::Config::Logger') }

  before do
    Timecop.freeze(Time.local(2025, 3, 3))
    allow(Sentry).to receive(:capture_exception)
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

  context 'without timestamps' do
    let(:params) do
      {
        controller_name: 'NextGen::Controllers::MarketAutomationController',
        action_name: 'execute_job',
        data: {}
      }
    end

    it do
      controller_instance = instance_double('NextGen::Controllers::MarketAutomationController')

      expect(NextGen::Controllers::MarketAutomationController)
        .to receive(:new).with({})
        .and_return(controller_instance)
      expect(controller_instance).to receive(:execute_job).and_return(true)

      described_class.new(params).call
      expect(ENV.fetch('DATETIME', nil)).to eq '2025-03-03 00:00:00 +0000'
    end
  end

  context 'with valid timestamps' do
    let(:timestamp_end) { 1_741_046_400_000 }
    let(:params) do
      {
        controller_name: 'NextGen::Controllers::MarketAutomationController',
        action_name: 'execute_job',
        data: {
          interval: '1h',
          limit: 50,
          timestamps: {
            start: 1_740_866_400_000,
            end: timestamp_end
          }
        }
      }
    end

    it do
      controller_instance = instance_double('NextGen::Controllers::MarketAutomationController')
      expect(NextGen::Controllers::MarketAutomationController)
        .to receive(:new).with(params[:data])
        .and_return(controller_instance)
      expect(controller_instance).to receive(:execute_job).and_return(true)

      described_class.new(params).call
      expect(ENV.fetch('DATETIME', nil)).to eq '2025-03-04 00:00:00 +0000'
    end
  end

  context 'when an error is raised in the controller' do
    let(:params) do
      {
        controller_name: 'NextGen::Controllers::MarketAutomationController',
        action_name: 'execute_job',
        data: {}
      }
    end

    it do
      error = StandardError.new('Something went wrong')
      controller_instance = instance_double('NextGen::Controllers::MarketAutomationController')

      allow(NextGen::Controllers::MarketAutomationController)
        .to receive(:new).and_return(controller_instance)
      allow(controller_instance)
        .to receive(:execute_job)
        .and_raise(error)

      allow(NextGen::Config::Logger).to receive(:instance).and_return(logger)
      expect(logger).to receive(:error).with("Error occured: #{error.message}")
      expect(Sentry).to receive(:capture_exception).with(error)

      expect { described_class.new(params).call }.to raise_error(StandardError, 'Something went wrong')
    end
  end
end
