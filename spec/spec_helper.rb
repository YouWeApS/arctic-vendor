require "bundler/setup"

require "simplecov"
SimpleCov.start

require "arctic/vendor"
require 'arctic/validation_api'
require 'webmock/rspec'
require 'rspec/its'
require 'timecop'
require 'active_support/all'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) { Arctic.logger = Logger.new '/dev/null' }
end

RSpec.shared_context :authenticated do |id: nil, token: nil|
  id ||= SecureRandom.uuid
  token ||= SecureRandom.uuid

  before do
    allow(ENV).to receive(:fetch).with('VENDOR_ID').and_return id
    allow(ENV).to receive(:fetch).with('VENDOR_TOKEN').and_return token
    basic_authorize id, token
  end
end
