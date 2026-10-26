gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

create_file "netlify.toml", <<~TOML
[build]
  command = "bundle install && bin/rails perron:build"
  publish = "output"

  [build.environment]
    RAILS_ENV = "production"
    RUBY_VERSION = "4.0.0"
[context.production.environment]
  PERRON_HOST = "yourdomain.com"
  PERRON_PROTOCOL = "https"
TOML
end
