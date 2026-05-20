namespace :perron do
  desc "Generate static HTML files from Perron collections"
  task build: :environment do
    unless Rails.env.production?
      puts "⚠️  Not running in production mode. Unpublished content will be included in the build."
      puts " └─> Run in production mode using: RAILS_ENV=production bin/rails perron:build"
      puts ""
    end

    Perron::Site.build
  end
end

Rake::Task["assets:precompile"].enhance do
  next if Perron.configuration.mode.standalone?

  Perron::Site.build
end
