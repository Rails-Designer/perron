require "test_helper"

class Perron::Resource::SourceableTest < ActiveSupport::TestCase
  setup do
    @output_dir = Rails.root.join("app/content/products")
  end

  teardown do
    FileUtils.rm_rf(@output_dir) if @output_dir.exist?
  end

  test ".sources sets source names and definitions" do
    assert_equal [:countries, :products], Content::Product.source_names
    assert_equal :id, Content::Product.source_definitions[:countries][:primary_key]
    assert_equal :code, Content::Product.source_definitions[:products][:primary_key]
  end

  test ".source_backed? returns true when sources defined" do
    assert Content::Product.source_backed?
  end

  test ".source_backed? returns false when no sources defined" do
    assert_equal [], Content::Page.source_names
    refute Content::Page.source_backed?
  end

  test ".generate_from_sources! creates files for all combinations" do
    Content::Product.generate_from_sources!

    assert_path_exists @output_dir.join("us-iphone-15.erb")
    assert_path_exists @output_dir.join("uk-iphone-15.erb")
    assert_path_exists @output_dir.join("us-ipad-pro.erb")
    assert_path_exists @output_dir.join("uk-ipad-pro.erb")
  end

  test ".generate_from_sources! writes correct frontmatter" do
    Content::Product.generate_from_sources!

    content = File.read(@output_dir.join("us-iphone-15.erb"))

    assert_match(/product_code: iphone-15/, content)
    assert_match(/country_id: us/, content)
    assert_match(/title: iPhone in United States/, content)
  end

  test "#sources loads source data from frontmatter" do
    FileUtils.mkdir_p(@output_dir)
    test_file = @output_dir.join("test.erb")
    File.write(test_file, <<~CONTENT)
      ---
      product_code: iphone-15
      country_id: us
      ---
    CONTENT

    resource = Content::Product.new(test_file.to_s)

    assert_equal "1", resource.sources.products.id
    assert_equal "iphone-15", resource.sources.products.code
    assert_equal "iPhone", resource.sources.products.name
    assert_equal "iphone", resource.sources.products.slug
    assert_equal "999", resource.sources.products.price
    assert_equal "us", resource.sources.countries.id
    assert_equal "United States", resource.sources.countries.name
    assert_equal "US", resource.sources.countries.code
  end

  test "#source_backed? returns true for source-backed resource instance" do
    FileUtils.mkdir_p(@output_dir)
    test_file = @output_dir.join("test.erb")
    File.write(test_file, "---\nproduct_code: iphone-15\n---")

    resource = Content::Product.new(test_file.to_s)

    assert resource.source_backed?
  end
end
