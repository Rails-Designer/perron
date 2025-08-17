# frozen_string_literal: true

require "perron/site/builder/assets"
require "perron/site/builder/sitemap"
require "perron/site/builder/feeds"
require "perron/site/builder/public_files"
require "perron/site/builder/paths"
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

        puts "\n📝 Generating collections…"

        paths.each { render_page(it) }

        Perron::Site::Builder::Sitemap.new(@output_path).generate
        Perron::Site::Builder::Feeds.new(@output_path).generate

        puts "\n✅ Build complete"
      end

      private

      def paths
        Set.new.tap do |paths|
          Perron::Site.collections.each { Perron::Site::Builder::Paths.new(it, paths).get }
        end.to_a
      end

      def render_page(path) = Perron::Site::Builder::Page.new(path).render
    end
  end
end
