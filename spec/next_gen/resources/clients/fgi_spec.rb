# frozen_string_literal: true

RSpec.describe NextGen::Clients::Fgi do
  let(:params) { { limit: 6 } }

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
        expect(response.count).to eq 6

        first_fgi = response.first
        expect(first_fgi['value']).to eq '15'
        expect(first_fgi['value_classification']).to eq 'Extreme Fear'
        expect(first_fgi['timestamp']).to eq '1741046400'
        expect(first_fgi['time_until_update']).to eq '55004'

        file_path = 'spec/data/2025-03-04/fgi.json'
        saved_data = JSON.parse(File.read(file_path))
        expect(saved_data.count).to eq 6
        expect(saved_data.first['value']).to eq '15'
      end
    end

    context 'already call for today' do
      it do
        expect(RestClient).not_to receive(:get)

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
