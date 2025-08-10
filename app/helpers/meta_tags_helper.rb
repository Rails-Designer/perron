# frozen_string_literal: true

module MetaTagsHelper
  def meta_tags(options = {}) = Perron::Metatags.new(resource).render(options)

  private

  Resource = Data.define(:path, :metadata, :published_at)

  def resource
    return Source.new(request.path, @metadata, nil) if @metadata.present?

    @resource || Resource.new(request.path, {}, nil)
  end
end
