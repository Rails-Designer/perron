# frozen_string_literal: true

require "perron/json_ld/schemas/base"

module Perron::JsonLd::Schemas
  class CommentSchema < Base
    private

    def properties
      {
        text: data.text,
        dateCreated: data.date_created,
        author: {
          "@type": "Person",
          name: data.author&.name
        }
      }
    end
  end
end
