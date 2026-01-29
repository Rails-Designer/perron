namespace :perron do
  task :set_production_env do
    unless ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = "production"
      puts "RAILS_ENV not set, defaulting to production"
    end
  end

  desc "Generate static HTML files from Perron collections"
  task build: [:set_production_env, :environment] do
    Perron::Site.build
  end
end

Rake::Task["assets:precompile"].enhance do
  next if Perron.configuration.mode.standalone?

  Perron::Site.build
end
