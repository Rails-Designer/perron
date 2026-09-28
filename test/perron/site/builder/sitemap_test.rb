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
    assert_includes urls, "http://#{host}/custom-set-slug/"
    assert_includes urls, "http://#{host}/invalid/"
    assert_includes urls, "http://#{host}/team/"
    assert_includes urls, "http://#{host}/version.json"
    assert_includes urls, "http://#{host}/authors/rails-designer.html"
    assert_includes urls, "http://#{host}/authors/not-rails-designer.html"
    assert_includes urls, "http://#{host}/blog/"
    assert_includes urls, "http://#{host}/blog/another-post/template.rb"

    refute_includes urls, "http://#{host}/features/"
  end

  test "sitemap uses resource updated_at as lastmod when present" do
    Perron.configuration.sitemap.enabled = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate

    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)
    host = Perron.configuration.default_url_options[:host]

    sample_post_lastmod = sitemap.xpath("//url[loc[text()='http://#{host}/blog/sample-post/']]/lastmod").text
    assert_equal "2023-05-15", sample_post_lastmod
  end

  test "sitemap omits lastmod when updated_at is missing" do
    Perron.configuration.sitemap.enabled = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate

    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)

    another_post_lastmod = sitemap.xpath("//url[loc[contains(text(),'another-post')]]/lastmod")
    assert_empty another_post_lastmod, "lastmod should not be present when updated_at is missing"
  end

  test "excludes url whose canonical points to another host" do
    Perron.configuration.sitemap.enabled = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate
    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)
    urls = sitemap.xpath("//url/loc").map(&:text)
    host = Perron.configuration.default_url_options[:host]
    refute_includes urls, "http://#{host}/blog/canonical-elsewhere/"
  end

  test "excludes url whose canonical points to another path" do
    Perron.configuration.sitemap.enabled = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate
    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)
    urls = sitemap.xpath("//url/loc").map(&:text)
    host = Perron.configuration.default_url_options[:host]
    refute_includes urls, "http://#{host}/blog/canonical-other/"
  end

  test "keeps url whose canonical matches itself" do
    Perron.configuration.sitemap.enabled = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate
    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)
    urls = sitemap.xpath("//url/loc").map(&:text)
    host = Perron.configuration.default_url_options[:host]
    assert_includes urls, "http://#{host}/blog/canonical-self/"
  end

  test "canonical_mismatch? is scheme-insensitive and safe" do
    builder = Perron::Site::Builder::Sitemap.new("output")
    assert_equal false, builder.send(:canonical_mismatch?, "http://h/x", "https://h/x")
    assert_equal true, builder.send(:canonical_mismatch?, "/x", "http://h/y")
    assert_equal false, builder.send(:canonical_mismatch?, nil, "http://h/x")
    assert_equal false, builder.send(:canonical_mismatch?, false, "http://h/x")
  end

  test "omits priority and changefreq by default" do
    Perron.configuration.sitemap.enabled = true
    Perron.configuration.sitemap.emit_priority = false
    Perron.configuration.sitemap.emit_changefreq = false
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate
    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)
    assert_empty sitemap.xpath("//url/priority")
    assert_empty sitemap.xpath("//url/changefreq")
  end

  test "emits priority and changefreq when enabled" do
    Perron.configuration.sitemap.enabled = true
    Perron.configuration.sitemap.emit_priority = true
    Perron.configuration.sitemap.emit_changefreq = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate
    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)
    refute_empty sitemap.xpath("//url/priority")
    refute_empty sitemap.xpath("//url/changefreq")
  end

  test "additional routes have no lastmod" do
    Perron.configuration.sitemap.enabled = true
    Perron::Site::Builder::Sitemap.new(Rails.root.join("output")).generate
    sitemap = Nokogiri::XML(File.read("test/dummy/output/sitemap.xml")).tap(&:remove_namespaces!)
    host = Perron.configuration.default_url_options[:host]
    assert_empty sitemap.xpath("//url[loc[text()='http://#{host}/']]/lastmod")
    assert_empty sitemap.xpath("//url[loc[text()='http://#{host}/version.json']]/lastmod")
  end

  test "last_modified_for returns nil when no resource has updated_at" do
    builder = Perron::Site::Builder::Sitemap.new("output")

    resource = Class.new do
      def buildable? = true

      def metadata
        Class.new { def updated_at = nil }.new
      end
    end.new

    collection = Class.new do
      define_method(:load_resources) { [resource] }
    end.new

    assert_nil builder.send(:last_modified_for, collection)
  end
end
