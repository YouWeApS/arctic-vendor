
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "arctic/vendor/version"

Gem::Specification.new do |spec|
  spec.name          = "arctic-vendor"
  spec.version       = Arctic::Vendor::VERSION
  spec.authors       = ["Emil Kampp"]
  spec.email         = ["emil@kampp.me"]

  spec.summary       = "Core API communcation from and to vendors"
  spec.description   = "This exposes a series of normal usage endpoints for Vendors to communicate with the Core API"
  spec.homepage      = "https://github.com/YouWeApS/arctic-vendor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  # spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "faraday", "~> 0.14"
  spec.add_runtime_dependency "activesupport", "~> 5.2"
end
