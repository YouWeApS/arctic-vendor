require "spec_helper"

RSpec.describe Arctic do
  describe '.logger' do
    subject { described_class.logger }
    it { is_expected.to be_a Logger }
  end

  describe '.logger=' do
    it 'overrides the default logger' do
      new_logger = Logger.new '/dev/null'
      described_class.logger = new_logger
      expect(described_class.logger).to eql new_logger
    end
  end
end
