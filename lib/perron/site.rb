# frozen_string_literal: true

require "perron/collection"
require "perron/data"
require "perron/data/proxy"
require "perron/site/builder"
require "perron/site/validate"

module Perron
  module Site
    module_function

    def build = Perron::Site::Builder.new.build

    def validate = Perron::Site::Validate.new.validate

    def collections
      Dir.children(Perron.configuration.input)
        .select { File.directory?(File.join(Perron.configuration.input, it)) }
        .reject { it == "data" }
        .map { Collection.new(it) }
    end

    def collection(name) = Collection.new(name)

    def data(name = nil)
      Perron.deprecator.deprecation_warning(:data, "Use Content::Data::ClassName instead, e.g. `Content::Data::Users.all`")

      (name && Perron::Data.new(name)) || Perron::Data::Proxy.new
    end
  end
end
