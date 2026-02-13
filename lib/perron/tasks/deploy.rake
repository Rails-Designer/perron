namespace :perron do
  desc "Deploy static site using Beam Up"
  task deploy: :environment do
    config = Perron.configuration.deploy
    provider = config.provider.to_s
    provider_config = config.send(provider).to_h

    provider_config[:provider] = provider

    BeamUp.deploy!(
      Perron.configuration.output,
      provider_config.merge(
        before_actions: ["bundle exec rake perron:build"],
        after_actions: ["bundle exec rake perron:clobber"]
      )
    )
  end
end
