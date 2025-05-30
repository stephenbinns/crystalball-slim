# typed: true
# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
require "rspec/sorbet"
SimpleCov.start
SimpleCov.add_filter "bundle/"
SimpleCov.add_filter "spec/support/shared_contexts/"

Dir[Pathname(__dir__).join("support", "**", "*.rb")].each { |f| require f }

RSpec::Sorbet.allow_doubles!

require "crystalball"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    ENV["CRYSTALBALL_LOG_FILE"] = File::NULL
  end
end
