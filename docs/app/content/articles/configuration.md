---
section: getting_started
position: 2
title: Configuration
description: Perron's global configuration is set in an Initializer.
toc: false
---

Set Perron's global configuration in `config/initializers/perron.rb`. This file is automatically created with `bin/rails perron:install`.

It looks something like this:
```ruby
Perron.configure do |config|
  config.site_name = "Perron"

  # Enable Live Reload with DOM Morphing in development
  # config.live_reload = true

  # config.default_url_options = {host: "perron.railsdesigner.com", protocol: "https", trailing_slash: true}
end
```

## All settings

Below are available settings:

- **site_name**; used as fallback for meta tags
- **site_description**; used as fallback for meta description
- **output**; location for site build, defaults to `/output/`
- **mode**; `:standalone` or `:integrated`, defaults to `standalone`
- **default_url_options**; set options for route helpers. Override with `PERRON_HOST`, `PERRON_PROTOCOL` and `PERRON_TRAILING_SLASH`.
- **search_scope**; scopes available for search (used by [search-form element](/library/search-form/))
- **live_reload**; automatically reload the page on changes in development (uses the [Mata](https://github.com/Rails-Designer/mata) gem)
- **output_server_strict**; when serving from output directory, only serve existing files (no dynamic fallback)
- **additional_routes**: array of route helper names to include in the build beyond collections (e.g., `%w[root_path robots_path]`). Defaults to `%w[root_path]` in `:standalone` mode and `[]` in `:integrated` mode
- **allowed_extensions**; set which extensions for content files are allowed, defaults to `%w[erb md]`
- **exclude_from_public**; exclude directories with compiled files should be excluded from `public`, defaults to `%w[assets storage]`
- **excluded_assets**; exclude which assets shoud be excluded when compiling, defaults to `%w[action_cable actioncable actiontext activestorage rails-ujs trix turbo]`
- **view_unpublished**; option to show [unpublished content](/docs/publishing/) content, defaults to `Rails.env.development?`. Can be overridden with `VIEW_UNPUBLISHED` environment variable
- **default_processors**; array of processors to run on every markdownify call (see [Markdown](/docs/markdown/#default-processors))
- **before_build**; lambda called before the build process (see [Deploy](/docs/deploy/#build-hooks))
- **after_build**; lambda called after a successful build (see [Deploy](/docs/deploy/#build-hooks))
- **cache_data_sources**; cache data sources
- **markdown_parser**; specifiy custom markdown parser
- **markdown_options**; pass options to the installed markdown gem
- **sitemap.enabled**; enable creation of the [sitemap.xml](/docs/xml-sitemap/), defaults to `false`
- **sitemap.priority**; default priority for sitemap items, defaults to `0.5`
- **sitemap.change_frequency**;  defaults to `:monthly`
