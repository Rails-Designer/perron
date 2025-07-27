# frozen_string_literal: true

require "perron/site/builder"
require "perron/site/collection"
require "perron/site/resource"
require "perron/site/data"
require "perron/site/data/proxy"

module Perron
  module Site
    module_function

    def build = Perron::Site::Builder.new.build

    def name = Perron.configuration.site_name

    def email = Perron.configuration.site_email

    def url
      options = Perron.configuration.default_url_options

      "#{options[:protocol]}://#{options[:host]}"
    end

    def collections
      @collections ||= Dir.children(Perron.configuration.input)
        .select { File.directory?(File.join(Perron.configuration.input, it)) }
        .map { Collection.new(it) }
    end

    def collection(name) = Collection.new(name)

    def data(name = nil)
      (name && Perron::Data.new(name)) || Perron::Data::Proxy.new
    end
  end
end
