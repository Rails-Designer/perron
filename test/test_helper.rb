ENV["RAILS_ENV"] = "test"

require File.expand_path("dummy/config/environment.rb", __dir__)
require "rails/test_help"
require "minitest/mock"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
