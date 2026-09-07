say "Install Perron in your Rails app"

say "Create Perron initializer"
copy_file "#{__dir__}/install/initializer.rb", "config/initializers/perron.rb"

say "Create content data directory"
copy_file "#{__dir__}/install/README.md", "app/content/data/README.md"

say "Add Markdown gem options to Gemfile"
append_to_file "Gemfile", <<~RUBY

  # Perron supports Markdown rendering using one of the following gems.
  # Uncomment your preferred choice and run `bundle install`
  # gem "commonmarker"
  # gem "kramdown"
  # gem "redcarpet"
RUBY

copy_file "#{__dir__}/assets/icon.png", "public/icon.png", force: true
copy_file "#{__dir__}/assets/icon.svg", "public/icon.svg", force: true

say "Add output folder to .gitignore"
append_to_file ".gitignore", "/#{Perron.configuration.output}/\n"
