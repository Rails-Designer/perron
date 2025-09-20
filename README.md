# Perron

A Rails-based static site generator.

**Sponsored By [Rails Designer](https://railsdesigner.com/)**

<a href="https://railsdesigner.com/" target="_blank">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Rails-Designer/perron/HEAD/.github/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Rails-Designer/perron/HEAD/.github/logo-light.svg">
    <img alt="Rails Designer" src="https://raw.githubusercontent.com/Rails-Designer/perron/HEAD/.github/logo-light.svg" width="240" style="max-width: 100%;">
  </picture>
</a>


## Getting started

### Installation

Start by adding Perron:
```bash
bundle add perron
```

Then generate the initializer:
```bash
rails generate perron:install
```


This creates an initializer:
```ruby
Perron.configure do |config|
  config.site_name = "Helptail"
end
```


## Mode

Perron can operate in two modes, configured via `config.mode`. This allows a build to be either a full static site or be integrated pages in a dynamic Rails application.

| **Mode** | `:standalone` (default) | `:integrated` |
| :--- | :--- | :--- |
| **Use Case** | Full static site for hosts like Netlify/Vercel | Add static pages to a live Rails app |
| **Output** | `output/` directory | `public/` directory |
| **Asset Handling** | Via Perron | Via Asset Pipeline |


## Collections

Perron is, just like Rails, designed with convention over configuration in mind. Content is stored in `app/content/*/*.{erb,md,*}` and backed by a class, located in `app/models/content/` that inherits from `Perron::Resource`.

The controllers are located in `app/controllers/content/`. To make them available, create a route: `resources :posts, module: :content, only: %w[index show]`.


### Create a new collection

```bash
bin/rails generate content Post
```

This will create the following files:

* `app/models/content/post.rb`
* `app/controllers/content/posts_controller.rb`
* `app/views/content/posts/index.html.erb`
* `app/views/content/posts/show.html.erb`

And adds a route: `resources :posts, module: :content, only: %w[index show]`


### Routes

Perron uses standard Rails routing, allowing the use of familiar route helpers. For a typical “clean slug”, the filename without extensions serves as the `id` parameter.
```ruby
<%# For app/content/pages/about.md %>
<%= link_to "About Us", page_path("about") %> # => <a href="/about/">About Us</a>
```

To create files with specific extensions directly (e.g., `pricing.html`), the route must first be configured to treat the entire filename as the ID. In `config/routes.rb`, modify the generated `resources` line by adding a `constraints` option:

```ruby
# Change from…
resources :pages, module: :content, only: %w[show]

# …to…
resources :pages, module: :content, only: %w[show], constraints: { id: /[^\/]+/ }
```

With this change, a content file named `app/content/pages/pricing.html.erb` can be linked like so:
```ruby
<%= link_to "View Pricing", page_path("pricing", format: :html) %> # => <a href="/pricing.html">View Pricing</a>
```

Perron will then create `pricing.html`.


### Setting a root page

To set a root page, include `Perron::Root` in your `Content::PagesController` and add a `app/content/pages/root.{md,erb,*}` file. Then add `root to: "content/pages#root"` add the bottom of your `config/routes.erb`.

This is automatically added for you when you create a `Page` collection.


## Markdown support

Perron supports markdown with the `markdownify` helper.

There are no markdown gems bundled by default, so you'll need to add one of these to your `Gemfile`:

- `commonmarker`
- `kramdown`
- `redcarpet`

```bash
bundle add {commonmarker,kramdown,redcarpet}
```

### Configuration

To pass options to the parser, set `markdown_options` in `config/initializers/perron.rb`. The options hash is passed directly to the chosen library.

**Commonmarker**
```ruby
# Options are passed as keyword arguments.
Perron.configuration.markdown_options = { options: [:HARDBREAKS], extensions: [:table] }
```

**Kramdown**
```ruby
# Options are passed as a standard hash.
Perron.configuration.markdown_options = { input: "GFM", smart_quotes: "apos,quot" }
```

**Redcarpet**
```ruby
# Options are nested under :renderer_options and :markdown_options.
Perron.configuration.markdown_options = {
  renderer_options: { hard_wrap: true },
  markdown_options: { tables: true, autolink: true }
}
```


## HTML transformations

Perron can post-process the HTML generated from your Markdown content.


### Usage

Apply transformations by passing an array of processor names or classes to the `markdownify` helper via the `process` option.
```erb
<%= markdownify @resource.content, process: %w[lazy_load_images syntax_highlight target_blank] %>
```


### Available processors

The following processors are built-in and can be activated by passing their string name:

- `target_blank`: Adds `target="_blank"` to all external links;
- `lazy_load_images`: Adds `loading="lazy"` to all `<img>` tags.
- `syntax_highlight`: Applies syntax highlighting to fenced code blocks (e.g., \`\`\`ruby). This requires adding the `rouge` gem to your Gemfile (`bundle add rouge`). You will also need to include a Rouge CSS theme for colors to appear.


### Creating your own processors

You can create your own processor by defining a class that inherits from `Perron::HtmlProcessor::Base` and implements a `process` method.
Then, pass the class constant directly in the `process` array.

```ruby
# app/processors/add_nofollow_processor.rb
class AddNofollowProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("a[target=_blank]").each { it["rel"] = "nofollow" }
  end
end
```

```erb
<%= markdownify @resource.content, process: ["target_blank", AddNofollowProcessor] %>
```


### Embed Ruby

Perron provides flexible options for embedding dynamic Ruby code in your content using ERB.


#### 1. File extension

Any content file with a `.erb` extension (e.g., `about.erb`) will automatically have its content processed as ERB.


#### 2. Frontmatter

You can enable ERB processing on a per-file basis, even for standard `.md` files, by adding `erb: true` to the file's frontmatter.
```markdown
---
title: Dynamic Page
erb: true
---

This entire page will be processed by ERB.
The current time is: <%= Time.current.to_fs(:long_ordinal) %>.
```


#### 3. `erbify` helper

For the most granular control, the `erbify` helper allows to process specific sections of a file as ERB.
This is ideal for generating dynamic content like lists or tables from your resource's metadata, without needing to enable ERB for the entire file. The `erbify` helper can be used with a string or, more commonly, a block.

**Example:** Generating a list from frontmatter data in a standard `.md` file.
```markdown
---
title: Features
features:
  - Rails based
  - SEO friendly
  - Markdown first
  - ERB support
---

Check out our amazing features:

<%= erbify do %>
  <ul>
    <% @resource.metadata.features.each do |feature| %>
      <li>
        <%= feature %>
      </li>
    <% end %>
  </ul>
<% end %>
```


## Data files

Perron can consume structured data from YML, JSON, or CSV files, making them available within your templates.
This is useful for populating features, team members, or any other repeated data structure.

### Usage

To use a data file, instantiate `Perron::Site.data` with the basename of the file and iterate over the result.
```erb
<% Perron::Site.data.features.each do |feature| %>
  <h4><%= feature.name %></h4>
  <p><%= feature.description %></p>
<% end %>
```

### File location and formats

By default, Perron looks up `app/content/data/` for files with a `.yml`, `.json`, or `.csv` extension.
For a `features` call, it would find `features.yml`, `features.json`, or `features.csv`. You can also provide a path to any data file, via `Perron::Data.new("path/to/data.json")`.

### Accessing data

The wrapper object provides flexible, read-only access to each record's attributes. Both dot notation and hash-like key access are supported.
```ruby
feature.name
feature[:name]
```

### Rendering

You can render data collections directly using Rails-like partial rendering. When you call `render` on a data collection, Perron will automatically render a partial for each item.
```erb
<%= render Perron::Site.data.features %>
```

This expects a partial at `app/views/content/features/_feature.html.erb` that will be rendered once for each feature in your data file. The individual record is made available as a local variable matching the singular form of the collection name.
```erb
<!-- app/views/content/features/_feature.html.erb -->
<div class="feature">
  <h4><%= feature.name %></h4>
  <p><%= feature.description %></p>
</div>
```


## Feeds

The `feeds` helper automatically generates HTML `<link>` tags for your site's RSS and JSON feeds.


### Usage

In your layout (e.g., `app/views/layouts/application.html.erb`), add the helper to the `<head>` section:
```erb
<head>
  …
  <%= feeds %>
  …
</head>
```

To render feeds for specific collections, such as `posts`:
```erb
<%= feeds only: %w[posts] %>
```

Similarly, you can exclude collections:
```erb
<%= feeds except: %w[pages] %>
```


### Configuration

Feeds are configured within the `Resource` class corresponding to a collection:
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  configure do |config|
    config.feeds.rss.enabled = true
    # config.feeds.rss.title = "My RSS feed" # defaults to configured site_name
    # config.feeds.rss.description = "My RSS feed description" # defaults to configured site_description
    # config.feeds.rss.path = "path-to-feed.xml"
    # config.feeds.rss.max_items = 25
    #
    config.feeds.json.enabled = true
    # config.feeds.json.title = "My JSON feed" # defaults to configured site_name
    # config.feeds.json.description = "My JSON feed description" # defaults to configured site_description
    # config.feeds.json.max_items = 15
    # config.feeds.json.path = "path-to-feed.json"
  end
end
```


## Metatags

The `meta_tags` helper automatically generates SEO and social sharing meta tags for your pages.

### Usage

In your layout (e.g., `app/views/layouts/application.html.erb`), add the helper to the `<head>` section:
```erb
<head>
  …
  <%= meta_tags %>
  …
</head>
```

You can render specific subsets of tags:
```erb
<%= meta_tags only: %w[title description] %>
```

Or exclude certain tags:
```erb
<%= meta_tags except: %w[twitter_card twitter_image] %>
```

### Priority

Values are determined with the following precedence, from highest to lowest:

#### 1. Controller action

Define a `@metadata` instance variable in your controller:
```ruby
class Content::PostsController < ApplicationController
  def index
    @metadata = {
      title: "All Blog Posts",
      description: "A collection of our articles."
    }
    @resources = Content::Post.all
  end
end
```

#### 2. Page frontmatter

Add values to the YAML frontmatter in content files:
```yaml
---
title: My Awesome Post
description: A deep dive into how meta tags work.
image: /assets/images/my-awesome-post.png
author: Kendall
---

Your content here…
```

#### 3. Collection configuration

Set collection defaults in the resource model:
```ruby
class Content::Post < Perron::Resource
  Perron.configure do |config|
    # …

    config.metadata.description = "Put your routine tasks on autopilot"
    config.metadata.author = "Helptail team"
  end
end
```

#### 4. Default values

Set site-wide defaults in the initializer:
```ruby
Perron.configure do |config|
  # …

  config.metadata.description = "Put your routine tasks on autopilot"
  config.metadata.author = "Helptail team"
end
```


## Related resources

The `related_resources` method allows to find and display a list of similar resources
from the sme collection. Similarity is calculated using the **[TF-IDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf)** algorithm on the content of each resource.


### Basic usage

To get a list of the 5 most similar resources, call the method on any resource instance.
```ruby
# app/views/content/posts/show.html.erb
@resource.related_resources

# Just the 3 most similar resources
@resource.related_resources(limit: 3)
```


## XML sitemap

A sitemap is a XML file that lists all the pages of a website to help search engines discover and index content more efficiently, typically containing URLs, last modification dates, change frequency, and priority values.

Enable it with the following line in the Perron configuration:
```ruby
Perron.configure do |config|
  # …
  config.sitemap.enabled = true
  # config.sitemap.priority = 0.8
  # config.sitemap.change_frequency = :monthly
  # …
end
```

Values can be overridden per collection…
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  configure do |config|
    config.sitemap.enabled = false
    config.sitemap.priority = 0.5
    config.sitemap.change_frequency = :weekly
  end
end
```

…or on a resource basis:
```ruby
# app/content/posts/my-first-post.md
---
sitemap_priority: 0.25
sitemap_change_frequency: :daily
---
```


## Building your static site

When in `standalone` mode and you're ready to generate your static site, run:
```bash
RAILS_ENV=production rails perron:build
```

This will create your static site in the configured output directory (`output` by default).


## Sites using Perron

Sites that use Perron.

### Standalone (as a SSG)
- [AppRefresher](https://apprefresher.com)
- [Helptail](https://helptail.com)

### Integrated (part of a Rails app)
- [Rails Designers (private community for Rails UI engineers)](https://railsdesigners.com)


## Contributing

This project uses [Standard](https://github.com/testdouble/standard) for formatting Ruby code. Please run `be standardrb` before submitting pull requests. Run tests with `rails test`.


## License

Perron is released under the [MIT License](https://opensource.org/licenses/MIT).
