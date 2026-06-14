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

        Read more: https://perron.railsdesigner.com/docs/deploy/
      MSG
    end

    beamed = BeamUp.with_progress do
      BeamUp.deploy!(
        Perron.configuration.output,
        config_file: "config/deploy.yml"
      )
    end

    puts beamed.message
    puts "Deploy ID: #{beamed.deploy_id}" if beamed.deploy_id
  end

  namespace :deploy do
    desc "Initialize deploy configuration with Beam Up"
    task :init, [:provider] do |task, arguments|
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

      path = BeamUp.init!(arguments[:provider], config_file: "config/deploy.yml")

      puts "Configured Beam Up in #{path}"
    end
  end
end
