
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arctic/vendor/version'

Gem::Specification.new do |spec|
  spec.name          = 'arctic-vendor'
  spec.version       = Arctic::Vendor::VERSION
  spec.authors       = ['YouWe']
  spec.email         = ['info@youwe.dk']

  spec.summary       = 'Core API communcation from and to vendors'
  spec.description   = 'This exposes a series of normal usage endpoints for Vendors to communicate with the Core API'
  spec.homepage      = 'https://github.com/YouWeApS/arctic-vendor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency 'webmock', "~> 3.4"
  spec.add_development_dependency 'rake', "~> 13.0"
  spec.add_development_dependency 'rspec', "~> 3.0"
  spec.add_development_dependency 'rspec-its', "~> 1.2"
  spec.add_development_dependency 'timecop', "~> 0.9"
  spec.add_development_dependency 'rack-test', "~> 1.1"
  spec.add_development_dependency 'hashie', "~> 3.6"
  spec.add_development_dependency 'simplecov', '~> 0.16'
  # spec.add_development_dependency 'pry'
  # spec.add_development_dependency 'pry-byebug'

  spec.add_runtime_dependency 'guard-rspec'
  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'activesupport', "~> 5.2"
  spec.add_runtime_dependency 'typhoeus', "~> 1.3"
  spec.add_runtime_dependency 'faraday_middleware'
  spec.add_runtime_dependency 'faraday-detailed_logger'
  spec.add_runtime_dependency 'grape', "~> 1.1"
  spec.add_runtime_dependency 'grape_logging', "~> 1.8"
  spec.add_runtime_dependency 'log_formatter', "~> 0.8"
  spec.add_runtime_dependency 'rollbar'
  # spec.add_runtime_dependency 'pry'
  # spec.add_runtime_dependency 'pry-byebug'
end
