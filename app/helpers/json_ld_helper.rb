# frozen_string_literal: true

module JsonLdHelper
  def json_ld_tags(with: nil)
    Perron::JsonLd.new(with || resource.metadata.fetch(:json_ld, [])).render
  end

  private

  Resource = Data.define(:path, :collection, :metadata, :published_at)

  def resource
    return Resource.new(request.path, nil, @metadata, nil) if @metadata.present?

    @resource || Resource.new(request.path, nil, {}, nil)
  end
end
