require "test_helper"

class Perron::Site::Resource::SlugTest < ActiveSupport::TestCase
  def setup
    @root_page = "test/dummy/app/content/pages/root.erb"
    @normal_page = "test/dummy/app/content/pages/about.md"
    @custom_page = "test/dummy/app/content/pages/custom.md"

    @dated_post = "test/dummy/app/content/posts/2023-05-15-sample-post.md"
  end

  def test_create_with_root_page
    resource = Perron::Resource.new(@root_page)
    frontmatter = Perron::Resource::Separator.new(resource.raw_content).frontmatter
    slug = Perron::Resource::Slug.new(resource, frontmatter)

    assert_equal "/", slug.create
  end

  def test_create_with_normal_page
    resource = Perron::Resource.new(@normal_page)
    frontmatter = Perron::Resource::Separator.new(resource.raw_content).frontmatter
    slug = Perron::Resource::Slug.new(resource, frontmatter)

    assert_equal "about", slug.create
  end

  def test_create_with_custom_slug
    resource = Perron::Resource.new(@custom_page)
    frontmatter = Perron::Resource::Separator.new(resource.raw_content).frontmatter
    slug = Perron::Resource::Slug.new(resource, frontmatter)

    assert_equal "custom-set-slug", slug.create
  end

  def test_create_with_dated_post
    resource = Perron::Resource.new(@dated_post)
    frontmatter = Perron::Resource::Separator.new(resource.raw_content).frontmatter
    slug = Perron::Resource::Slug.new(resource, frontmatter)

    assert_equal "sample-post", slug.create
  end

  test "create appends preview token when previewable" do
    resource = Content::Feature.new("test/dummy/app/content/features/beta-feature.md")
    frontmatter = Perron::Resource::Separator.new(resource.raw_content).frontmatter
    slug = Perron::Resource::Slug.new(resource, frontmatter)

    assert slug.create.start_with?("beta-feature-")
    assert_equal 25, slug.create.length # "beta-feature-" (13) + token (12)
  end
end
