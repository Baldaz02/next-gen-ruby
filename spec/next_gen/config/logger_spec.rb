# frozen_string_literal: true

RSpec.describe NextGen::Config::Logger do
  let(:log_directory) { 'spec/data/log' }
  let(:log_file) { "#{log_directory}/2025-03-14.log" }
  let(:logger) { described_class.instance }

  before { Timecop.freeze(Time.local(2025, 3, 14)) }
  after { FileUtils.rm_f(log_file) }

  context 'write message' do
    it do
      logger.info('Compiled test ok')

      expect(File).to exist(log_file)
      log_content = File.read(log_file)
      expect(log_content).to include('INFO -- : Compiled test ok')

      logger.error('Compiled test failed')

      expect(File).to exist(log_file)
      log_content = File.read(log_file)
      expect(log_content).to include('ERROR -- : Compiled test failed')
    end
  end
end
