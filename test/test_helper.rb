ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Ensure URL helpers don't require locale in tests
Rails.application.routes.default_url_options[:locale] = nil

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Disable fixture loading since we use FactoryBot
    self.use_instantiated_fixtures = false
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
