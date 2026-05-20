# frozen_string_literal: true

module Perron
  module MetaTagsHelper
    def meta_tags(options = {})
      metadata = (@metadata || {}).merge(@resource&.metadata || {})

      Perron::Metatags.new(metadata).render(options)
    end
  end
end
