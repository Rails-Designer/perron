require "test_helper"

class Perron::Resource::PreviewableTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @preview_feature_path = "test/dummy/app/content/features/beta-feature.md"
    @custom_preview_feature_path = "test/dummy/app/content/features/custom-preview-feature.md"
    @public_feature_path = "test/dummy/app/content/features/public-feature.md"

    @preview_feature = Content::Feature.new(@preview_feature_path)
    @custom_preview_feature = Content::Feature.new(@custom_preview_feature_path)
    @public_feature = Content::Feature.new(@public_feature_path)
  end

  teardown { travel_back }

  test "#previewable? returns false when preview not set" do
    refute @public_feature.previewable?
  end

  test "#previewable? returns true when preview is true" do
    assert @preview_feature.previewable?
  end

  test "#preview? alias of #previewable?" do
    assert @preview_feature.preview?
  end

  test "#preview_token returns nil when not previewable" do
    assert_nil @public_feature.preview_token
  end

  test "#preview_token generates deterministic token when preview is true" do
    token1 = @preview_feature.preview_token

    @preview_feature.instance_variable_set(:@preview_token, nil)

    token2 = @preview_feature.preview_token

    assert_equal token1, token2
    assert_equal 12, token1.length
  end

  test "#preview_token returns custom value when preview is string" do
    assert @custom_preview_feature.previewable?

    assert_equal "custom-token", @custom_preview_feature.preview_token
  end

  test "#previewable? works with scheduled content" do
    scheduled_feature_path = "test/dummy/app/content/features/scheduled-feature.md"
    scheduled_feature = Content::Feature.new(scheduled_feature_path)

    travel_to Time.zone.local(2024, 1, 1) do
      assert scheduled_feature.previewable?
      assert scheduled_feature.scheduled?

      refute scheduled_feature.published?
    end
  end
end
