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

    config = Rails.root.join("config/deploy.yml")

    unless config.exist?
      puts "config/deploy.yml not found. Creating from template…"
      puts "Read more: https://perron.railsdesigner.com/docs/deploy/"

      template = File.expand_path("../../install/deploy.yml", __dir__)
      FileUtils.cp(template, config)

      puts "Created config/deploy.yml"
    end

    result = BeamUp.with_progress do
      BeamUp.deploy!(
        Perron.configuration.output,
        config_file: "config/deploy.yml"
      )
    end

    puts result.message
    puts "Deploy ID: #{result.deploy_id}" if result.deploy_id
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

      provider = arguments[:provider]

      unless provider
        puts "Usage: rake perron:deploy:init[provider]"
        puts "Available: #{BeamUp::PROVIDERS.keys.reject { it == "transporter" }.sort.join(", ")}"

        exit 1
      end

      path = BeamUp.init!(provider, config_file: "config/deploy.yml")

      puts "Configured #{provider} in #{path}"
    end
  end
end
