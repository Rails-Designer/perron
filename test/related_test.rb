require "test_helper"

class RelatedTest < ActiveSupport::TestCase
  setup do
    @main_product = Perron::Site.collection("products").resources.find { it.filename == "main-product.md" }
  end

  test "initialization succeeds with a valid resource" do
    assert_nothing_raised do
      Perron::Site::Resource::Related.new(@main_product)
    end
  end

  test "#find returns a correctly ranked list of related products" do
    related_products = @main_product.related_resources(limit: 3)
    related_slugs = related_products.map(&:slug)

    expected_order = [
      "most-similar-product", # Highest similarity: "ruby", "development", "professional"
      "less-similar-product", # Medium similarity: "development"
      "unrelated-product"     # No meaningful shared keywords
    ]

    assert_equal expected_order, related_slugs, "Products are not ranked by similarity correctly"
  end

  test "#find respects the limit parameter" do
    limited_results = @main_product.related_resources(limit: 1)

    assert_equal 1, limited_results.size
    assert_equal "most-similar-product.md", limited_results.first.filename
  end

  test "#find does not include the source product in the results" do
    related_products = @main_product.related_resources

    refute_includes related_products.map(&:id), @main_product.id, "Source product should not be in its own related list"
  end

  test "#find returns an array of Perron::Resource instances" do
    related_products = @main_product.related_resources

    assert_kind_of Array, related_products
    assert_kind_of Content::Product, related_products.first if related_products.any?
  end
end
