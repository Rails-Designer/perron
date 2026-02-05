# frozen_string_literal: true

require "perron/site/builder/assets"
require "perron/site/builder/sitemap"
require "perron/site/builder/feeds"
require "perron/site/builder/public_files"
require "perron/site/builder/paths"
require "perron/site/builder/additional_routes"
require "perron/site/builder/page"

module Perron
  module Site
    class Builder
      def initialize
        @output_path = Rails.root.join(Perron.configuration.output)
      end

      def build
        if Perron.configuration.mode.standalone?
          puts "🧹 Cleaning previous build…"

          FileUtils.rm_rf(Dir.glob("#{@output_path}/*"))

          Perron::Site::Builder::Assets.new.prepare
          Perron::Site::Builder::PublicFiles.new.copy
        end

        locales = Perron.configuration.locales

        puts "\n📝 Generating collections…"
        if locales.present?
          render_pages_for(locales)
        else
          paths.each { render_page(it) }
        end

        Perron::Site::Builder::Sitemap.new(@output_path).generate
        Perron::Site::Builder::Feeds.new(@output_path).generate

        output_preview_urls

        puts "\n✅ Build complete"
      end

      private

      def render_pages_for(locales)
        locales.each do |locale|
          I18n.with_locale(locale) do
            paths.each { render_page(it, locale) }
          end
        end
      end

      def paths
        Set.new.tap do |paths|
          Perron::Site::Builder::AdditionalRoutes.new(paths).get
          Perron::Site::Builder::Paths.new(paths).get
        end
      end

      def render_page(path, locale = nil) = Perron::Site::Builder::Page.new(path, locale).render

      def output_preview_urls
        previewable_resources = Perron::Site.collections.flat_map { it.send(:load_resources) }.select(&:previewable?)

        if previewable_resources.any?
          puts "\n🔒 Preview URLs:"
          previewable_resources.each do |resource|
            puts "   #{Rails.application.routes.url_helpers.polymorphic_url(resource, **Perron.configuration.default_url_options)}"
          end
        end
      end
    end
  end
end
