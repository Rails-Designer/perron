# frozen_string_literal: true

module Perron
  class Resource
    module Publishable
      extend ActiveSupport::Concern

      included do
        def published?
          return true if Perron.configuration.view_unpublished

          return false if frontmatter.draft == true
          return false if frontmatter.published == false
          return false if publication_date&.after?(Time.current)

          true
        end

        def buildable?
          published? || previewable?
        end

        def scheduled? = publication_date&.after?(Time.current)

        def draft?
          frontmatter.draft == true || frontmatter.published == false
        end

        def publication_date
          @publication_date ||= begin
            from_meta = frontmatter.published_at.present? ? begin
              Time.zone.parse(frontmatter.published_at.to_s)
            rescue
              nil
            end : nil

            from_meta || date_from_filename
          end
        end
        alias_method :published_at, :publication_date

        def scheduled_at
          publication_date if scheduled?
        end
      end

      private

      DATE_REGEX = /^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})-/

      def date_from_filename
        return @date_from_filename if defined?(@date_from_filename)

        match = File.basename(file_path).match(DATE_REGEX)
        @date_from_filename = match ? Date.new(match[:year].to_i, match[:month].to_i, match[:day].to_i).in_time_zone : nil
      end
    end
  end
end
