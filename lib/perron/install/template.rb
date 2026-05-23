gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  gsub_file "Gemfile", /gem "sqlite3".*$/, ""
  gsub_file "Gemfile", /gem "activerecord".*$/, ""

  say "Remove files"
  remove_file "config/database.yml"
  remove_file "config/credentials.yml.enc"
  remove_file "config/master.key"
  remove_file "public/400.html"
  remove_file "public/406-unsupported-browser.html"
  remove_file "public/422.html"
  remove_file "public/500.html"
  remove_file "app/controllers/application_controller.rb"
  remove_file "app/views/layouts/application.html.erb"
  remove_file "README.md"

  run "rm -r app/views/pwa" if File.directory?("app/views/pwa")

  append_to_file ".gitignore", "/output/\n" if File.exist?(".gitignore")

  say "Create application files"
  create_file "app/controllers/application_controller.rb", <<~RB
    class ApplicationController < ActionController::Base
    end
  RB

  create_file "app/views/layouts/application.html.erb", <<~ERB
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <%= meta_tags %>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
    
        <%= yield :head %>
    
        <link rel="icon" href="/icon.png" type="image/png">
        <link rel="icon" href="/icon.svg" type="image/svg+xml">
        <link rel="apple-touch-icon" href="/icon.png">
    
        <%= stylesheet_link_tag :app %>
        <!-- Learn more on https://attractivejs.railsdesigner.com/ -->
        <script defer src="https://cdn.jsdelivr.net/npm/attractivejs@latest"></script>
      </head>
      <body>
        <%= yield %>
      </body>
    </html>
  ERB

  create_file "README.md", <<~MARKDOWN
    # #{app_name.titleize}

    TBD


    ## Development

    ```
    bin/dev
    ```


    ## Deploy/publish

    ```
    bin/perron build
    ```
  MARKDOWN

  markdown_gem = ask("Which markdown parser would you like to use? (commonmarker/kramdown/redcarpet or leave blank to skip):")

  gem_name = markdown_gem.strip.downcase
  if %w[commonmarker kramdown redcarpet].include?(gem_name)
    uncomment_lines "Gemfile", /gem "#{gem_name}"/

    Bundler.with_unbundled_env { run "bundle install" }
  elsif markdown_gem.present?
    say "Invalid markdown parser option. Skipping…", :yellow
  end
end
