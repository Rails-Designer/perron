# frozen_string_literal: true

require "perron/site/builder/assets"
require "perron/site/builder/sitemap"
require "perron/site/builder/feeds"
require "perron/site/builder/public_files"
require "perron/site/builder/paths"
require "perron/site/builder/additional_routes"
require "perron/site/builder/page"
require "perron/site/builder/benchmark"
require "parallel"

module Perron
  module Site
    class Builder
      def initialize
        @output_path = Rails.root.join(Perron.configuration.output)
      end

      def build
        @benchmark = Benchmark.new
        @benchmark.start

        if Perron.configuration.mode.standalone?
          @benchmark.phase("Clean") do
            puts "🧹 Cleaning previous build…"
            FileUtils.rm_rf(Dir.glob("#{@output_path}/*"))
          end

          @benchmark.phase("Assets") do
            Perron::Site::Builder::Assets.new.prepare
          end

          @benchmark.phase("Public files") do
            Perron::Site::Builder::PublicFiles.new.copy
          end
        end

        puts "\n📝 Generating collections…"

        @benchmark.phase("Collect paths") do
          @paths = paths
        end

        if Perron.configuration.parallel_rendering
          @benchmark.phase("Page rendering (parallel)") do
            render_pages_in_parallel
          end
        else
          @benchmark.phase("Page rendering (sequential)") do
            render_pages_sequentially
          end
        end

        @benchmark.phase("Sitemap") do
          Perron::Site::Builder::Sitemap.new(@output_path).generate
        end

        @benchmark.phase("Feeds") do
          Perron::Site::Builder::Feeds.new(@output_path).generate
        end

        output_preview_urls

        @benchmark.summary

        puts "\n✅ Build complete"
      end

      private

      def paths
        Set.new.tap do |paths|
          Perron::Site::Builder::AdditionalRoutes.new(paths).get
          Perron::Site::Builder::Paths.new(paths).get
        end
      end

      def render_pages_sequentially
        @paths.each do |path|
          result = Page.new(path, benchmark: @benchmark).render

          display_error(result)
        end
      end

      def render_pages_in_parallel
        print_mutex = Mutex.new

        results = Parallel.map(@paths.to_a, threads: thread_count) do |path|
          result = Page.new(path, benchmark: @benchmark).render

          print_mutex.synchronize { print "\e[32m.\e[0m" }

          result
        end

        results.each { |result| display_error(result) if result }
      end

      def display_error(result)
        return if result.success

        puts "\n  ❌ ERROR: Failed to generate page for '#{result.path}'. Details: #{result.error}"
      end

      def thread_count
        Perron.configuration.build_threads || Parallel.processor_count
      end

      def output_preview_urls
        previewable_resources = Perron::Site.collections.flat_map { it.send(:load_resources) }.select(&:previewable?)

        return unless previewable_resources.any?

        puts "\n🔒 Preview URLs:"
        previewable_resources.each do |resource|
          puts "   #{Rails.application.routes.url_helpers.polymorphic_url(resource, **Perron.configuration.default_url_options)}"
        end
      end
    end
  end
end
