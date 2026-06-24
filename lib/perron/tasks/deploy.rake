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

    config_file = "config/deploy.yml" if Rails.root.join("config/deploy.yml").exist?
    config_file = "config/deploy.yml.erb" if Rails.root.join("config/deploy.yml.erb").exist?

    if config_file.nil?
      FileUtils.cp(File.expand_path("../install/deploy.yml.erb", __dir__), Rails.root.join("config/deploy.yml.erb"))
      config_file = "config/deploy.yml.erb"
      puts "Created config/deploy.yml.erb"
    end

    beamed = BeamUp.with_progress do
      BeamUp.deploy!(
        Perron.configuration.output,
        config_file: config_file
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

      config_file = "config/deploy.yml" if Rails.root.join("config/deploy.yml").exist?
      config_file = "config/deploy.yml.erb" if Rails.root.join("config/deploy.yml.erb").exist?

      if config_file.nil?
        config_file = "config/deploy.yml.erb"
      end

      path = BeamUp.init!(arguments[:provider], config_file: config_file)

      puts "Configured Beam Up in #{path}"
    end
  end
end
