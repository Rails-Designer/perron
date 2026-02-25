require "test_helper"

class Perron::Site::Builder::SitemapTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    FileUtils.rm_rf("test/dummy/output")

    FileUtils.mkdir_p("test/dummy/output")
  end

  teardown do
    FileUtils.rm_rf("test/dummy/output")
  end

  test "does not create sitemap.xml if disabled globally" do
    Perron.configuration.sitemap.enabled = false

    Perron::Site::Builder::Sitemap.new("output").generate

    refute File.exist?("test/dummy/output/sitemap.xml"), "sitemap.xml should not be created when generation is disabled"
  end

  test "creates sitemap.xml with correct content and respects all rules" do
    Perron.configuration.sitemap.enabled = true

    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate

    assert File.exist?("test/dummy/output/sitemap.xml"), "sitemap.xml should be created at the configured output path"

    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)
    urls = sitemap.xpath("//url/loc").map(&:text)
    host = Perron.configuration.default_url_options[:host]

    assert_includes urls, "http://#{host}/"
    assert_includes urls, "http://#{host}/about/"
    refute_includes urls, "http://#{host}/blog/"
  end

  test "sitemap uses resource updated_at as lastmod when present" do
    Perron.configuration.sitemap.enabled = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate

    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)

    sample_post_lastmod = sitemap.xpath("//url[loc[contains(text(),'sample-post')]]/lastmod").text
    assert_equal "2023-05-15", sample_post_lastmod
  end

  test "sitemap omits lastmod when updated_at is missing" do
    Perron.configuration.sitemap.enabled = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate

    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)

    another_post_lastmod = sitemap.xpath("//url[loc[contains(text(),'another-post')]]/lastmod")
    assert_empty another_post_lastmod, "lastmod should not be present when updated_at is missing"
  end
end
