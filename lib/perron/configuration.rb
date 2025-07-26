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

      @config.output = "output"

      @config.mode = :standalone
      @config.include_root = false

      @config.site_name = nil

      @config.allowed_extensions = [".erb", ".md"]
      @config.exclude_from_public = %w[assets storage]
      @config.excluded_assets = %w[action_cable actioncable actiontext activestorage rails-ujs trix turbo]

      @config.default_url_options = {
        host: ENV.fetch("PERRON_HOST", "localhost:3000"),
        protocol: ENV.fetch("PERRON_PROTOCOL", "http"),
        trailing_slash: ENV.fetch("PERRON_TRAILING_SLASH", "true") == "true"
      }

      @config.metadata = ActiveSupport::OrderedOptions.new
      @config.metadata.title_separator = " — "
    end

    def input = "app/content"

    def output
      mode.integrated? ? "public" : @config.output
    end

    def mode = @config.mode.to_s.inquiry

    def exclude_root? = !@config.include_root

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
