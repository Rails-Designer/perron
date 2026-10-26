---
section: getting_started
position: 2.5
title: Development
description: Work efficiently with live reload, hot module replacement, and local preview.
---

Perron provides several features to help you development your Perron-powered site.

## Running the server

Start your Rails development server with `bin/dev` or `rails server`.


## Live reload

Enable live reload to automatically refresh the browser when content changes:
```ruby
Perron.configure do |config|
  config.live_reload = true
end
```

This uses the [Mata](https://github.com/Rails-Designer/mata) gem to inject a script that watches for changes and morphs the DOM for a smoother experience than full page reloads.


## Local preview

Preview the built static site locally using:
```bash
RAILS_ENV=production rails perron:build && bin/dev
```

Requests are served from the `output/` directory when files exist. By default, the Output Server falls back to Rails rendering for any missing static HTML. Disable this behavior by setting `config.output_server_strict = true`. The Output Server will now raise a 404 for missing pages.


> [!note]
> When serving from the output directory in development the browser's tab title is prefixed with `[PREVIEW]`.


### Remove local build

Use `rails perron:clobber` to remove the output directory and return to fully dynamic rendering.
