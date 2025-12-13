require "test_helper"

class Perron::Site::Resource::PublishableTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @page_path = "test/dummy/app/content/pages/about.md"
    @post_path = "test/dummy/app/content/posts/2023-05-15-sample-post.md"

    @page_resource = Content::Page.new(@page_path)
    @post_resource = Content::Post.new(@post_path)
  end

  teardown { travel_back }

  test "#published? returns true in development environment" do
    original_env = Rails.env

    begin
      Rails.env = "development"

      assert @page_resource.published?
    ensure
      Rails.env = original_env
    end
  end

  test "#publication_date extracts date from filename" do
    expected_date = Time.zone.local(2023, 5, 15)

    assert_equal expected_date, @post_resource.publication_date
  end

  test "#published_at is an alias for publication_date" do
    assert_equal @post_resource.publication_date, @post_resource.published_at
  end

  test "#scheduled? determines if post is scheduled for future" do
    travel_to Time.zone.local(2023, 1, 1) do
      assert @post_resource.scheduled?
    end

    travel_to Time.zone.local(2024, 1, 1) do
      refute @post_resource.scheduled?
    end
  end

  test "#scheduled_at returns publication_date when scheduled" do
    travel_to Time.zone.local(2023, 1, 1) do
      assert_equal @post_resource.publication_date, @post_resource.scheduled_at
    end
  end

  test "#scheduled_at returns nil when not scheduled" do
    travel_to Time.zone.local(2024, 1, 1) do
      assert_nil @post_resource.scheduled_at
    end
  end

  test "#draft? returns true when draft is true" do
    draft_feature = Content::Feature.new("test/dummy/app/content/features/beta-feature.md")

    assert draft_feature.draft?
  end

  test "#draft? returns true when published is false" do
    unpublished_feature = Content::Feature.new("test/dummy/app/content/features/custom-preview-feature.md")

    assert unpublished_feature.draft?
  end

  test "#draft? returns false for published content" do
    public_feature = Content::Feature.new("test/dummy/app/content/features/public-feature.md")

    refute public_feature.draft?
  end
end
