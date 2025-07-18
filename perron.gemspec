require_relative "lib/perron/version"

Gem::Specification.new do |spec|
  spec.name = "perron"
  spec.version = Perron::VERSION
  spec.authors = ["Rails Designer Developers"]
  spec.email = "devs@railsdeigner.com"

  spec.summary = "Rails-based static site generator"
  spec.description = "Perron is a Rails-based static site generator that follows Rails conventions. It allows you to create content collections with markdown or ERB, configure SEO metadata, and build production-ready static sites while leveraging your existing Rails knowledge with familiar patterns and minimal configuration."
  spec.homepage = "https://github.com/Rails-Designer/perron"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Rails-Designer/perron/"

  spec.files = Dir["{bin,app,lib}/**/*", "Rakefile", "README.md", "perron.gemspec", "Gemfile", "Gemfile.lock"]

  spec.required_ruby_version = ">= 3.4.0"

  spec.add_dependency "rails", ">= 7.2.0"
end
