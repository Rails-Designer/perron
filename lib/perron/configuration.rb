# frozen_string_literal: true

module Perron
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    def initialize
      @config = ActiveSupport::OrderedOptions.new

      @config.site_name = nil
      @config.site_description = nil

      @config.output = "output"

      @config.mode = :standalone

      @config.allowed_extensions = %w[erb md]

      @config.live_reload = false
      @config.live_reload_watch_paths = %w[app/content app/views app/assets]
      @config.live_reload_skip_paths = %w[app/assets/builds]

      @config.exclude_from_public = %w[assets storage]
      @config.excluded_assets = %w[action_cable actioncable actiontext activestorage rails-ujs trix turbo]

      @config.view_unpublished = Rails.env.development?

      @config.default_url_options = {
        host: ENV.fetch("PERRON_HOST", "localhost:3000"),
        protocol: ENV.fetch("PERRON_PROTOCOL", "http"),
        trailing_slash: ENV.fetch("PERRON_TRAILING_SLASH", "true") == "true"
      }

      @config.markdown_options = {}

      @config.search_scope = []

      @config.sitemap = ActiveSupport::OrderedOptions.new
      @config.sitemap.enabled = false
      @config.sitemap.priority = 0.5
      @config.sitemap.change_frequency = :monthly

      @config.metadata = ActiveSupport::OrderedOptions.new
      @config.metadata.title_separator = " — "
    end

    def input = Rails.root.join("app", "content")

    def output
      mode.integrated? ? "public" : @config.output
    end

    def mode = @config.mode.to_s.inquiry

    def additional_routes
      @additional_routes || (mode.integrated? ? [] : %w[root_path])
    end

    attr_writer :additional_routes

    def url
      options = Perron.configuration.default_url_options
      path = options[:trailing_slash] ? "/" : ""

      URI.join("#{options[:protocol]}://#{options[:host]}", path).to_s
    end

    def method_missing(method_name, ...)
      if @config.respond_to?(method_name)
        @config.send(method_name, ...)
      else
        super
      end
    end

    def respond_to_missing?(method_name)
      @config.respond_to?(method_name) || super
    end
  end
end
