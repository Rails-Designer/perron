gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

create_file "render.yaml", <<~YAML
services:
  - type: static
    name: my-perron-site
    buildCommand: bundle install && bin/rails perron:build
    staticPublishPath: ./output
    envVars:
      - key: RAILS_ENV
        value: production
      - key: RUBY_VERSION
        value: 3.4.5
    headers:
      - path: /*
        name: X-Frame-Options
        value: SAMEORIGIN
    routes:
      - type: rewrite
        source: /*
        destination: /index.html
YAML
end
