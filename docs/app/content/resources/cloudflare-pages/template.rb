gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

create_file "wrangler.toml", <<~TOML
  name = "my-perron-site"
  pages_build_output_dir = "./output"

  [vars]
    RAILS_ENV = "production"
    RUBY_VERSION = "3.4.5"
    PERRON_HOST = "yourdomain.com"
    PERRON_PROTOCOL = "https"
TOML
end
