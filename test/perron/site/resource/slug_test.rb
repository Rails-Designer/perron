require "test_helper"

class Perron::Site::Resource::SlugTest < ActiveSupport::TestCase
  def setup
    @dated_file = "test/dummy/app/content/posts/2023-05-15-sample-post.md"
    @normal_file = "test/dummy/app/content/pages/about.md"
    @custom_file = "test/dummy/app/content/pages/custom.md"
  end

  def test_create_with_dated_file
    resource = Perron::Resource.new(@dated_file)
    slug = Perron::Resource::Slug.new(resource)

    assert_equal "sample-post", slug.create
  end

  def test_create_with_normal_file
    resource = Perron::Resource.new(@normal_file)
    slug = Perron::Resource::Slug.new(resource)

    assert_equal "about", slug.create
  end

  def test_create_with_custom_slug
    resource = Perron::Resource.new(@custom_file)
    slug = Perron::Resource::Slug.new(resource)

    assert_equal "custom-set-slug", slug.create
  end
end
