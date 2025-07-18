require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  setup do
    @posts = Perron::Collection.new("posts")
    @pages = Perron::Collection.new("pages")
  end

  test "initialization sets name" do
    assert_equal "posts", @posts.name
    assert_equal "pages", @pages.name
  end

  test "initialization raises error when collection doesn't exist" do
    assert_raises Perron::Errors::CollectionNotFoundError do
      Perron::Collection.new("nonexistent")
    end
  end

  test "#all returns resources when given a resource class" do
    resources = @posts.all(Perron::Resource)

    assert_not_empty resources

    resources.each do |resource|
      assert_kind_of Perron::Resource, resource
    end
  end

  test "#all filters for published resources" do
    resources = @posts.all(Perron::Resource)

    resources.each do |resource|
      assert resource.published?
    end
  end

  test "#find returns a resource with the given slug" do
    travel_to Time.zone.local(2024, 1, 1) do
      resources = @posts.all(Perron::Resource)

      skip "No resources found to test with" if resources.empty?

      resource = resources.first
      slug = resource.slug
      found_resource = @posts.find(slug, Perron::Resource)

      assert_equal resource.id, found_resource.id
    end
  end

  test "#find raises error when resource with slug doesn't exist" do
    assert_raises Perron::Errors::ResourceNotFoundError do
      @posts.find("nonexistent-slug", Perron::Resource)
    end
  end
end
