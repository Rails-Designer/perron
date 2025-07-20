# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class PublicFiles
        def initialize
          @output_path = Rails.root.join(Perron.configuration.output)
          @public_dir = Rails.root.join("public")
        end

        def copy
          puts "📂 Copying public files…"

          return unless Dir.exist?(@public_dir)

          if paths.empty?
            puts "  - No public files to copy"

            return
          end

          paths.each do |path|
            FileUtils.cp_r(path, @output_path)

            puts "   ✅ Copied: #{File.basename(path)}"
          end
        end

        private

        def paths
          @paths ||= Dir.glob(File.join(@public_dir, "*")).reject do |path|
            Set.new(Perron.configuration.exclude_from_public + %w[. ..]).include?(File.basename(path))
          end
        end
      end
    end
  end
end
