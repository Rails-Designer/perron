---
section: render
position: 1
title: Markdown
description: Perron can render markdown with a flexible helper that has support for multiple markdown gems.
---

Perron supports markdown with the `markdownify` helper.

There are no markdown gems bundled by default, so add one of these to the `Gemfile`:

- `commonmarker`
- `kramdown`
- `redcarpet`

```bash
# choose one
bundle add {commonmarker,kramdown,redcarpet}
```

This set up allows to choose your favorite markdown renderer and update it separately from Perron.


## Markdownify helper

Once a markdown gem is installed, use the `markdownify` helper in any view and it will parse the content using the installed markdown parser, for example:
```erb
<article class="content">
  <h1>
    <%= @resource.title %>
  </h1>

  <%= markdownify @resource.content %>
</article>
```

Pass a block:
```erb
<article class="content">
  <h1>
    <%= @resource.title %>
  </h1>

  <%= markdownify do %>
    Perron supports markdown with the `markdownify` helper.

    There are no markdown gems bundled by default, so add one of these to the `Gemfile`:

    - `commonmarker`
    - `kramdown`
    - `redcarpet`

    ```bash
    bundle add {commonmarker,kramdown,redcarpet}
    ```
  <% end %>
</article>
```

## Configuration

To pass options to the parser, set `markdown_options` in `config/initializers/perron.rb`. The options hash is passed directly to the chosen library.

```ruby
Perron.configure do |config|
  # …
  # Commonmarker
  # Options are passed as keyword arguments.
  config.markdown_options = { options: { parse: { smart: true }, render: { unsafe: true } }

  # Kramdown
  # Options are passed as a standard hash.
  config.markdown_options = { input: "GFM", smart_quotes: "apos,quot" }

  # Redcarpet
  # Options are nested under :renderer_options and :markdown_options.
  config.markdown_options = {
    renderer_options: { hard_wrap: true },
    markdown_options: { tables: true, autolink: true }
  }

  # …
end
```


## Custom markdown parser

```ruby
class MyParser < Perron::Markdown::Parser
  def parse(text)
    # Do whatever you want here
    # `config.markdown_options` is available as `options` instance method
  end
end
```

Extend the `Perron::Markdown::Parser` class or any of the three provided markdown providers.

Then use it by setting `markdown_parser`:
```ruby
Perron.configure do |config|
  # …
  config.markdown_parser = :my_parser
  # …
end
```


## Processors

Perron can post-process the markdownified content using processors.


### Usage

Apply transformations by passing an array of processor names or classes to the `markdownify` helper via the `process` option.
```erb
<%= markdownify @resource.content, process: %w[lazy_load_images target_blank] %>
```


### Built-in processors

The following processors are built-in and can be activated by passing their string name:

- `absolute_image_urls`; converts relative image URLs to absolute using configured `default_url_options`
- `lazy_load_images`; adds `loading="lazy"` to all `<img>` tags
- `target_blank`; adds `target="_blank"` to all external links

> [!note]
> Processors are included as _first-party_ options only when they require no setup or configuration. Otherwise, they are added to the [library](/library/).


### Accessing @resource in processors

Processors have access to the the `@resource` instance variable assuming it is defined as such (e.g. `@resource = Content::Post.find!(params[:id])`).

If the resource object is named differently, e.g. `@post`, pass it along:
```erb
<%= markdownify @resource.content, process: %w[target_blank], resource: @post %>
```


### Create your own processor

Create your own processor by defining a class that inherits from `Perron::HtmlProcessor::Base` and implements a `process` method.
```ruby
# app/processors/add_nofollow_processor.rb
class AddNofollowProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("a[target=_blank]").each { it["rel"] = "nofollow" }
  end
end
```

> [!note]
> The `@html` instance variable is a `Nokogiri::HTML::DocumentFragment` object, that gives access to methods like `css()`, `xpath()` and DOM manipulation. See the [Nokogiri docs](https://nokogiri.org/) for more.

Then, pass the class constant directly in the `process` array.
```erb
<%= markdownify @resource.content, process: ["target_blank", AddNofollowProcessor] %>
```


### Default processors

Configure processors to run on every `markdownify` call:

```ruby
Perron.configure do |config|
  config.default_processors = [MyProcessor, "target_blank"]
end
```

Passing an explicit `process:` argument to `markdownify` overrides the defaults. To combine defaults with additional per-call processors in a specific view:

```erb
<%= markdownify @resource.content, process: Perron.configuration.default_processors + [MyExtraProcessor] %>
```
