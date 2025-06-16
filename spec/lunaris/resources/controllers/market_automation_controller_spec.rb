# frozen_string_literal: true

RSpec.describe Lunaris::Controllers::MarketAutomationController do
  let(:data) { { interval: '1h', limit: 50 } }
  let(:controller) { described_class.new(data) }

  describe '#execute_job' do
    it do
      job_instance = instance_double(Lunaris::Jobs::MarketAutomationJob)

      expect(Lunaris::Jobs::MarketAutomationJob).to receive(:new)
        .with(data)
        .and_return(job_instance)

      expect(job_instance).to receive(:perform).and_return(true)

      result = controller.execute_job
      expect(result).to eq(true)
    end
  end
end
