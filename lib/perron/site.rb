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
        .reject { it == "themes" } # TODO: remove me
        .map { Collection.new(it) }
    end

    def collection(name) = Collection.new(name)

    def data(name = nil)
      (name && Perron::Data.new(name)) || Perron::Data::Proxy.new
    end
  end
end
