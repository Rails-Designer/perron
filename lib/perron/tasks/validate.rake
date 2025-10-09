namespace :perron do
  desc "Validate all site resources"
  task validate: :environment do
    Perron::Site.validate
  end
end
