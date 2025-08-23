# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class Assets
        def initialize
          @output_path = Rails.root.join(Perron.configuration.output)
        end

        def prepare
          puts "📦 Precompiling and copying assets…"

          success = system("bundle exec rails assets:precompile", out: File::NULL, err: File::NULL)

          unless success
            puts "❌ ERROR: Asset precompilation failed"

            exit(1)
          end

          source = Rails.root.join("public", "assets")
          destination = @output_path.join("assets")

          unless Dir.exist?(source)
            puts "⚠️ WARNING: No assets found in `#{source}` to copy"

            return
          end

          FileUtils.mkdir_p(destination)
          FileUtils.cp_r(Dir.glob("#{source}/*"), destination)

          puts "   Copied assets to `#{destination.relative_path_from(Rails.root)}`"

          prune_excluded_assets from: destination
        end

        private

        def prune_excluded_assets(from:)
          return if exclusions.empty?

          puts "   Pruning excluded assets…"

          pattern = /^(#{exclusions.join("|")})(\.esm|\.min)?-[a-f0-9]{8,}/

          Dir.glob("#{from}/**/*").each do |path|
            next if File.directory?(path)

            filename = File.basename(path)

            if filename.match?(pattern)
              FileUtils.rm(path)

              map_file = "#{path}.map"

              FileUtils.rm(map_file) if File.exist?(map_file)
            end
          end
        end

        def exclusions = Perron.configuration.excluded_assets
      end
    end
  end
end
