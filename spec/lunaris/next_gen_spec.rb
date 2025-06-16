# frozen_string_literal: true

RSpec.describe(Lunaris) do
  before do
    allow(ENV).to receive(:[]).with('APP_INFO').and_return('telegram')
  end

  it('eager loads all files') do
    expect { Zeitwerk::Loader.eager_load_all }.not_to raise_error
  end

  describe('.version') do
    it('follows semver') { expect(described_class.version).to match(/\d\.\d\.\d\z/) }
  end

  describe('.app_info=') do
    it('set the app_info') do
      original_app_info = Lunaris::Base.app_info
      described_class.app_info = 'MyAppInfo'
      expect(Lunaris::Base.app_info).to eq('MyAppInfo')
      Lunaris::Base.app_info = original_app_info
    end
  end

  describe('.ping') do
    it('control if the gem is listening') do
      expect(Lunaris.ping[:status]).to eq(200)
    end
  end

  describe('.version') do
    it('control the version of the gem') do
      expect(Lunaris.version).to eq(Lunaris::VERSION)
    end
  end
end
