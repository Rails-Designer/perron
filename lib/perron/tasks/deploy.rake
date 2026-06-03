namespace :perron do
  desc "Deploy static site using Beam Up"
  task deploy: :environment do
    begin
      require "beam_up"
    rescue LoadError
      raise LoadError, <<~MSG
        Beam Up is required for the deploy task to run.

        Add it to your Gemfile:
          gem "beam_up"

        See for more: https://perron.railsdesigner.com/docs/deploy/
      MSG
    end

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
