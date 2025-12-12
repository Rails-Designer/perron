# frozen_string_literal: true

module Perron
  class Resource
    module Previewable
      extend ActiveSupport::Concern

      included do
        def previewable?
          frontmatter.preview.present? && (draft? || scheduled?)
        end

        def preview_token
          return nil unless previewable?

          @preview_token ||= if frontmatter.preview == true
            Digest::SHA256.hexdigest(file_path)[0..11]
          else
            frontmatter.preview
          end
        end
      end
    end
  end
end
