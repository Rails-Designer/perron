require "test_helper"

require "fileutils"

class SiteTest < ActiveSupport::TestCase
  setup do
    Perron.configure do |config|
      config.site_name = "Test Site"
      config.site_email = "test@example.com"
      config.default_url_options = { protocol: "https", host: "example.com" }
    end
  end

  test ".name returns the name from the configuration" do
    assert_equal "Test Site", Perron::Site.name
  end

  test ".email returns the email from the configuration" do
    assert_equal "test@example.com", Perron::Site.email
  end

  test ".url builds the URL from the configuration" do
    assert_equal "https://example.com", Perron::Site.url
  end
end
