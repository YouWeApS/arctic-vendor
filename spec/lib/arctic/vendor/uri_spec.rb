require "spec_helper"

RSpec.describe URI do
  let(:url) { 'https://google.com?search=hello' }

  describe '.replace_params' do
    subject { described_class.replace_params url, params }
    let(:params) { { search: 'me' } }
    it { expect(subject.query).to eql('search=me') }
  end

  describe '.params_hash' do
    subject { described_class.params_hash uri }
    let(:uri) { URI.parse url }
    it { is_expected.to eql 'search' => 'hello' }
  end
end
