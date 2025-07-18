namespace :perron do
  desc "Generate static HTML files from Perron collections"
  task build: :environment do
    Perron::Site.build
  end
end

Rake::Task["assets:precompile"].enhance do
  next if Perron.configuration.mode.standalone?

  Perron::Site.build
end
