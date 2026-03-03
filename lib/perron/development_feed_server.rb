# frozen_string_literal: true

module Perron
  class DevelopmentFeedServer
    def initialize(app)
      @app = app
    end

    def call(environment)
      request = Rack::Request.new(environment)

      if build_only_path?(request.path_info)
        render_message(request.path_info)
      else
        @app.call(environment)
      end
    end

    private

    def build_only_path?(path)
      sitemap?(path) || feed?(path)
    end

    def render_message(path)
      content_type = path.end_with?(".json") ? "application/json" : "application/xml"

      [
        200,

        {
          "Content-Type" => "#{content_type}; charset=utf-8",
          "Content-Length" => message(path).bytesize.to_s
        },

        [message(path)]
      ]
    end

    def sitemap?(path)
      path.match?(/\/sitemap\.xml$/)
    end

    def feed?(path)
      feed_paths.any? { path.end_with?("/#{it}") || path == "/#{it}" }
    end

    def message(path)
      if path.end_with?(".json")
        "{ \"message\": \"This feed is generated during build\" }"
      elsif sitemap?(path)
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n  <!-- Sitemap is generated during build -->\n</urlset>"
      else
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n  <!-- Feed is generated during build -->\n</feed>"
      end
    end

    def feed_paths
      @feed_paths ||= Perron::Site.collections.flat_map do |collection|
        config = collection.configuration
        next [] unless config && config[:feeds]

        config[:feeds].values.filter_map do |feed_config|
          feed_config[:path] if feed_config[:enabled]
        end
      end.compact
    end
  end
end
