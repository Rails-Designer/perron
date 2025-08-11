# frozen_string_literal: true

module MetaTagsHelper
  def meta_tags(options = {}) = Perron::Metatags.new(resource).render(options)

  private

  Resource = Data.define(:path, :collection, :metadata, :published_at)

  def resource
    return Resource.new(request.path, nil, @metadata, nil) if @metadata.present?

    @resource || Resource.new(request.path, nil, {}, nil)
  end
end
