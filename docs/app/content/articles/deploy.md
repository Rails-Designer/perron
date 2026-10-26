---
section: getting_started
position: 3
title: Deploy to production
description: Perron can be deployed as a static site (to platforms like Netlify, Seal Static and statichost.eu) or used within your Rails app.
---

Perron can operate in two modes, configured via `config.mode`. This allows a build to be either a full static site or be integrated pages in a dynamic Rails application.

**Full static sites** (`standalone` mode) can be deployed to any build-based platform, like [Netlify](/library/netlify/), [Seal Static](https://sealstatic.com) and [statichost.eu](/library/statichost/).

**Integrated sites** (`integrated` mode) work within a typical Rails application and can be deployed to any Rails host like Heroku or using Kamal.

| **Mode** | `standalone` (default) | `integrated` |
| :--- | :--- | :--- |
| **Use Case** | Full static site | Add static pages to a live Rails app |
| **Deployment** | Build-based platforms (Netlify, Seal Static, statichost.eu, etc.) | Traditional Rails hosts (Heroku, Kamal, etc.) |
| **Output** | `output/` directory | `public/` directory |
| **Asset Handling** | Via Perron | Via Asset Pipeline |

When in `standalone` mode and ready to generate your static site, run:
```bash
RAILS_ENV=production bundle install && rails perron:build
```

This will create static HTML files in the configured output directory (`output` by default).


## Deploy task

Perron provides a `perron:deploy` task that builds and deploys your site in one step. It uses [Beam Up](https://github.com/Rails-Designer/beam_up), which supports multiple providers including Netlify, [Seal Static](https://sealstatic.com) and statichost.eu.

Add Beam Up to your Gemfile:
```bash
bundle add beam_up
```

Then deploy:
```bash
RAILS_ENV=production rails perron:deploy
```

The task creates a `config/deploy.yml` file on first run if one does not exist:

```yaml
# config/deploy.yml
# provider: seal_static

# seal_static:
#   api_key: your_token_here

before_actions:
  - RAILS_ENV=production bundle exec rails perron:build
after_actions:
  - bundle exec rails perron:clobber
```

[Seal Static](https://sealstatic.com) is the default provider when no provider is configured.


### Deploy init

Generate provider-specific configuration:
```bash
rails perron:deploy:init
```

This interactively sets up configuration for the chosen provider and writes them to `config/deploy.yml`.

### Before and after actions

Use `before_actions` and `after_actions` in `config/deploy.yml` to run shell commands before or after the deploy:

```yaml
before_actions:
  - RAILS_ENV=production bundle exec rails perron:build
  - echo "Build complete, deploying…"

after_actions:
  - bundle exec rails perron:clobber
  - echo "Deploy complete!"
```


## Build hooks

Configure `before_build` and `after_build` callbacks to run logic around the build process:

```ruby
Perron.configure do |config|
  config.before_build = ->(context) {
    # do whatever before build
  }

  config.after_build = ->(context) {
    # do whatever after build succeeded
  }
end
```

The `context` object includes the site builder instance.

View the [Library](/library/#deployment) for deploy scripts to various platforms.
