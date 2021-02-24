require 'simplecov'
SimpleCov.start

require "bundler/setup"
require "nova/api"
require 'webmock/rspec'
require 'rspec/dry/struct'

require 'support/authorization_helper'

WebMock.disable_net_connect!

require 'byebug'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include AuthorizationHelper
end
