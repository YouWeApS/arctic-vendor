require 'log_formatter'
require 'log_formatter/ruby_json_formatter'
require "logger"

module Arctic
  def logger
    @logger ||= begin
      STDOUT.sync = true
      Logger.new STDOUT
    end

    @logger.formatter = Ruby::JSONFormatter::Base.new \
      ENV['HOST'] || 'arctic-vendor-gem',
      source: :ruby

    @logger
  end
  module_function :logger

  def logger=(new_logger)
    @logger = new_logger
  end
  module_function :logger=
end
