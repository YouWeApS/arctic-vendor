require "vendor/version"
require 'arctic/vendor/api'
require 'arctic/vendor/vendor'
require 'arctic/vendor/uri'

module Arctic
  def logger
    @logger ||= begin
      STDOUT.sync = true
      Logger.new STDOUT
    end
  end
  module_function :logger

  def logger=(new_logger)
    @logger = new_logger
  end
  module_function :logger=

  module Vendor
  end
end
