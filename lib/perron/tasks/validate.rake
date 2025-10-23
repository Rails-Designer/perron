namespace :perron do
  desc "Validate all site resources"
  task validate: :environment do
    abort if Perron::Site::Validate.new.tap(&:validate).failed?
  end
end
