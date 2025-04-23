# frozen_string_literal: true

RSpec.describe NextGen::Clients::Fgi do
  let(:params) { { limit: 6 } }
  let(:client) { described_class.new(params) }
  let(:aws_client) { instance_double("Clients::Aws") }
  let(:file_path) { 'spec/data/2025-03-04/fgi.json' }

  context '#values' do
    before do
      allow(aws_client).to receive(:invoke)

      stub_request(:post, 'https://lambda.eu-west-2.amazonaws.com/2015-03-31/functions/NextGen/invocations')
        .to_return(status: 200, body: load_fixture('fgi.json'))
    end

    context 'env datetime set to realtime' do
      before do
        ENV['DATETIME'] = DateTime.now.to_s
      end

      after(:all) do
        datetime = DateTime.parse(ENV['DATETIME'])
        dir_path = "spec/data/#{datetime.strftime('%Y-%m-%d')}"
        file_path = "#{dir_path}/fgi.json"
    
        File.delete(file_path) if File.exist?(file_path)
        Dir.rmdir(dir_path) if Dir.exist?(dir_path) && Dir.empty?(dir_path)
      end

      context 'not call today' do
        before do
          allow(File).to receive(:exist?).and_return(false)
        end
      
        it do
          response = client.values
          expect(response.count).to eq 6
      
          first_fgi = response.first
          expect(first_fgi['value']).to eq '15'
          expect(first_fgi['value_classification']).to eq 'Extreme Fear'
          expect(first_fgi['timestamp']).to eq '1741046400'
          expect(first_fgi['time_until_update']).to eq '55004'

          datetime = DateTime.parse(ENV['DATETIME'])
          file_path = "spec/data/#{datetime.strftime('%Y-%m-%d')}/fgi.json"
          saved_data = JSON.parse(File.read(file_path))
          expect(saved_data.count).to eq 6
          expect(saved_data.first['value']).to eq '15'
        end
      end

      context 'already call for today' do
        it do
          expect(aws_client).not_to receive(:invoke)

          response = client.values
          expect(response.count).to eq 6

          first_fgi = response.first
          expect(first_fgi['value']).to eq '15'
          expect(first_fgi['value_classification']).to eq 'Extreme Fear'
          expect(first_fgi['timestamp']).to eq '1741046400'
          expect(first_fgi['time_until_update']).to eq '55004'
        end
      end
    end

    context 'env datetime set to old date' do
      context 'not call today' do
        before do
          allow(File).to receive(:exist?).and_return(false)
        end

        it do
          expect(File.exist?(file_path)).to be_falsey

          response = client.values
          expect(response.count).to eq 6

          first_fgi = response.first
          expect(first_fgi['value']).to eq '15'
          expect(first_fgi['value_classification']).to eq 'Extreme Fear'
          expect(first_fgi['timestamp']).to eq '1741046400'
          expect(first_fgi['time_until_update']).to eq '55004'

          saved_data = JSON.parse(File.read(file_path))
          expect(saved_data.count).to eq 6
          expect(saved_data.first['value']).to eq '15'
        end
      end

      context 'already call for today' do
        it do
          expect(File.exist?(file_path)).to be_truthy
  
          expect(aws_client).not_to receive(:invoke)

          response = client.values
          expect(response.count).to eq 6

          first_fgi = response.first
          expect(first_fgi['value']).to eq '15'
          expect(first_fgi['value_classification']).to eq 'Extreme Fear'
          expect(first_fgi['timestamp']).to eq '1741046400'
          expect(first_fgi['time_until_update']).to eq '55004'
        end
      end
    end
  end
end
