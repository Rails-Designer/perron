gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  create_file "statichost.yml", <<~YAML
  image: ruby:3.4
  command: bundle install && RAILS_ENV=production bin/rails perron:build
  public: output
  YAML
end
