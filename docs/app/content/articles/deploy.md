---
section: getting_started
position: 3
title: Deploy to production
description: Perron can be deployed as a static site (to platforms like Netlify, S3 and statichost.eu) or used within your Rails app.
---

Perron can operate in two modes, configured via `config.mode`. This allows a build to be either a full static site or be integrated pages in a dynamic Rails application.

**Full static sites** (`standalone` mode) can be deployed to any build-based platform, like [Netlify](/library/netlify/), S3 and [statichost.eu](/library/statichost/).

**Integrated sites** (`integrated` mode) work within a typical Rails application and can be deployed to any Rails host like Heroku or using Kamal.

| **Mode** | `standalone` (default) | `integrated` |
| :--- | :--- | :--- |
| **Use Case** | Full static site | Add static pages to a live Rails app |
| **Deployment** | Build-based platforms (Netlify, S3, statichost.eu, etc.) | Traditional Rails hosts (Heroku, Kamal, etc.) |
| **Output** | `output/` directory | `public/` directory |
| **Asset Handling** | Via Perron | Via Asset Pipeline |

When in `standalone` mode and ready to generate your static site, run:
```bash
RAILS_ENV=production bundle install && rails perron:build
```

This will create static HTML files in the configured output directory (`output` by default).


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
