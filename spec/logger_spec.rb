require "spec_helper"
require 'hashie/mash'

RSpec.describe 'Arctic logger' do
  before do
    File.open './spec/test.log', 'w'
    Arctic.logger = Logger.new './spec/test.log'
    Arctic.logger.info({ a: :b, c: { d: :e } })
  end

  subject { Hashie::Mash.new JSON.parse(File.read('./spec/test.log')) }

  its(:a) { is_expected.to eql 'b' }
  its(:c) { is_expected.to eql 'd' => 'e' }
  its(:log_level) { is_expected.to eql 'INFO' }
  its(:log_app) { is_expected.to eql 'arctic-vendor-gem' }
  its(:log_timestamp) { is_expected.to be_present }
end
