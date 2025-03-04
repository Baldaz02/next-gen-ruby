# frozen_string_literal: true

RSpec.describe NextGen::Clients::Fgi do
  let(:params) { { limit: 10 } }

  let(:client) { described_class.new(OpenStruct.new(params)) }
  
  before { Timecop.freeze(Time.local(2025, 3, 4)) }

  context '#values' do
    context 'not call today' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        
        stub_request(:get, "#{described_class::BASE_URL}?limit=#{params[:limit]}")
          .to_return(status: 200, body: load_fixture('fgi.json'))
      end

      it do
        response = client.values
        expect(response['data'].count).to eq 10
        
        first_fgi = response['data'].first
        expect(first_fgi['value']).to eq '15'
        expect(first_fgi['value_classification']).to eq 'Extreme Fear'
        expect(first_fgi['timestamp']).to eq '1741046400'
        expect(first_fgi['time_until_update']).to eq '55004'

        file_path = client.send(:data_file_path)
        saved_data = JSON.parse(File.read(file_path))
        expect(saved_data['data'].count).to eq 10
        expect(saved_data['data'].first['value']).to eq '15'
      end
    end

    context 'already call for today' do
      it do
        expect(RestClient).not_to receive(:get)

        response = client.values
        expect(response['data'].count).to eq 10
        
        first_fgi = response['data'].first
        expect(first_fgi['value']).to eq '15'
        expect(first_fgi['value_classification']).to eq 'Extreme Fear'
        expect(first_fgi['timestamp']).to eq '1741046400'
        expect(first_fgi['time_until_update']).to eq '55004'
      end
    end
  end
end
