namespace :perron do
  desc "Deploy static site using Beam Up"
  task deploy: :environment do
    config = Perron.configuration.deploy
    provider = config.provider.to_s
    provider_config = config.send(provider).to_h

    provider_config[:provider] = provider

    Rake::Task["perron:build"].invoke

    BeamUp.deploy!(
      Perron.configuration.output,
      provider_config
    )

    Rake::Task["perron:clobber"].invoke
  end
end
