module ConfigurationHelper
  extend ActiveSupport::Concern

  included do
    setup do
      @default_attributes = {
        site_name: Perron.configuration.site_name,
        default_url_options: Perron.configuration.default_url_options.dup,
        metadata: Perron.configuration.metadata.dup
      }
    end

    teardown do
      Perron.configure do |config|
        config.site_name = @default_attributes[:site_name]
        config.default_url_options = @default_attributes[:default_url_options]
        config.metadata = @default_attributes[:metadata]
      end
    end
  end
end
