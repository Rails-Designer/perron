# frozen_string_literal: true

module MetaTagsHelper
  def meta_tags(options = {})
    Perron::Metatags.new(source).render(options)
  end

  private

  Source = Data.define(:path, :metadata, :published_at)

  def source
    return Source.new(request.path, @metadata, nil) if @metadata.present?

    @resource || Source.new(request.path, {}, nil)
  end
end
