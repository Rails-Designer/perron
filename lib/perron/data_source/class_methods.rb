# frozen_string_literal: true

module Perron
  class DataSource < SimpleDelegator
    module ClassMethods
      extend ActiveSupport::Concern

      class_methods do
        def all
          parts = name.to_s.split("::").drop(2)
          identifier = parts.empty? ? name.demodulize.underscore : parts.map(&:underscore).join("/")

          new(identifier)
        end

        def find(id)
          all.find { it[:id] == id || it["id"] == id }
        end

        def find!(id)
          data_source = all.find { it[:id] == id || it["id"] == id }

          return data_source if data_source

          raise Errors::DataSourceNotFoundError, "Row not found with id: #{id}"
        end

        def count = all.size

        def first = all.first

        def second = all[1]

        def third = all[2]

        def fourth = all[3]

        def fifth = all[4]

        def forty_two = all[41]

        def last = all.last

        def take(n) = all.first(n)

        def path_for(identifier)
          path = Pathname.new(identifier)

          return path.to_s if path.file? && path.absolute?

          base_path = Rails.root.join("app", "content", "data")
          locale = I18n.locale.to_s
          default_locale = Perron.configuration.default_locale&.to_s || Perron.configuration.locales&.first&.to_s

          locale_path = base_path.join(locale)

          candidates = SUPPORTED_EXTENSIONS.flat_map do |ext|
            [locale_path.join("#{identifier}#{ext}"), base_path.join("#{identifier}#{ext}")]
          end

          candidates.find(&:exist?)&.to_s
        end

        def path_for!(identifier)
          path_for(identifier).tap do |path|
            raise Errors::FileNotFoundError, "No data file found for `#{identifier}`" unless path
          end
        end

        def directory?(identifier) = Dir.exist?(Rails.root.join("app", "content", "data", identifier))
      end
    end
  end
end