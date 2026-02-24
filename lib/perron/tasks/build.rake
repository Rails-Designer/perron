namespace :perron do
  desc "Generate static HTML files from Perron collections"
  task build: :environment do
    unless Rails.env.production?
      puts "WARNING: Not running in production mode. Unpublished content will be included in the build."
      puts "  Run with: RAILS_ENV=production bin/rails perron:build"
    end

    Perron::Site.build
  end
end

Rake::Task["assets:precompile"].enhance do
  next if Perron.configuration.mode.standalone?

  Perron::Site.build
end
