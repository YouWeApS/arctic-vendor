require "spec_helper"

RSpec.describe 'VERSION' do
  it { expect(Arctic::Vendor::VERSION).to eql '2.5.20' }
end
