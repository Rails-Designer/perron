gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  run "npm install -g surge"

create_file "CNAME", <<~CNAME
# Add your custom domain
CNAME


create_file "bin/deploy", <<~BASH
#!/bin/bash
set -e

echo "Building site with Perron…"
RAILS_ENV=production bin/rails perron:build

echo "Deploying to Surge.sh…"
surge ./output

echo "Cleaning up…"
rm -rf ./output

echo "Deployed"
BASH

run "chmod +x bin/deploy"
end
