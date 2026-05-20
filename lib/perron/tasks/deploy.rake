require "beam_up"

namespace :perron do
  desc "Deploy static site using Beam Up"
  task deploy: :environment do
    config = Rails.root.join("config/deploy.yml")

    unless config.exist?
      puts "config/deploy.yml not found. Read more https://perron.railsdesigner.com/docs/deploy/"

      exit 1
    end

    BeamUp.deploy!(
      Perron.configuration.output,
      config_file: "config/deploy.yml"
    )
  end
end
