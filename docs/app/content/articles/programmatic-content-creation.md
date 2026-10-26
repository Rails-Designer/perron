---
section: content
position: 6
title: Programmatic content
description: Generate hundreds of pages from data sources for programmatic SEO and scalable content creation.
---

Generate content programmatically from [data sources](/docs/data/) instead of creating files manually. Define a template once and Perron creates resources for every combination of the data. Perfect to pull data from an API or for programmatic SEO where similar pages with different data are needed.


## Basic Usage

First create data resources:
```json
// app/content/data/countries.json
[
  {"id": "de", "name": "Germany"},
  {"id": "nl", "name": "The Netherlands"}
]
```

```csv
# app/content/data/products.csv
id,name,price
1,iPhone,999
2,iPad,799
```

Then configure in the content resource class:

```ruby
# app/models/content/product.rb
class Content::Product < Perron::Resource
  sources :countries, :products

  def self.source_template(source)
    <<~TEMPLATE
    ---
    title: #{source.products.name} in #{source.countries.name}
    country_id: #{source.countries.id}
    product_id: #{source.products.id}
    ---

    # #{source.products.name}

    Available in #{source.countries.name} for $#{source.products.price}.
    TEMPLATE
  end
end
```

> [!tip]
> Use the generator `bin/rails generate content Product --data countries.json products.csv`

Generate resources:

```bash
bin/rails perron:sync_sources
```

This creates four files in `app/content/products/`:
- `de-1.erb`
- `nl-1.erb`
- `de-2.erb`
- `nl-2.erb`

Each file is processed like any regular resource with full access to layouts, helpers and routing.


## Custom primary keys

By default, Perron uses `id` to identify records. Use the `primary_key` option to specify a different column:

```ruby
class Content::Product < Perron::Resource
  sources :countries, products: { primary_key: :code }

  def self.source_template(source)
    <<~TEMPLATE
    ---
    title: #{source.products.name}
    country_id: #{source.countries.id}
    product_code: #{source.products.code}
    ---
    TEMPLATE
  end
end
```

Filenames use the specified primary keys: `us-iphone-15.erb`


## Lambda filtering

Filter data sources using lambda expressions:
```ruby
class Content::Product < Perron::Resource
  sources, :countries,
    products: -> (products) { products.select(&:featured?) }

  def self.source_template(source)
    <<~TEMPLATE
    ---
    title: #{source.products.name} in #{source.countries.name}
    product_id: #{source.products.id}
    ---
    TEMPLATE
  end
end
```


## Single source

Use `source` (singular) for a single data source:
```ruby
class Content::City < Perron::Resource
  source :cities

  def self.source_template(source)
    <<~TEMPLATE
    ---
    title: #{source.cities.name}
    city_id: #{source.cities.id}
    ---
    TEMPLATE
  end
end
```


### Mode option

Control how data sources are combined using the `mode` option:
```ruby
# Default: Cartesian product of all data sources
source tools: { mode: :combinations }
```

With columns specified via `as:`:
```ruby
source tools: { mode: :combinations, as: [:left, :right] }
```


## Syncing

Sync all source-backed resources:
```bash
bin/rails perron:sync_sources
```

Sync a specific resource:
```bash
bin/rails perron:sync_sources[products]
```

> [!tip]
> In zsh, quote the task name: `bin/rails "perron:sync_sources[products]"`

Run the sync task whenever data changes to regenerate affected resources.


## API integration with custom classes

Use the `class` option to pull data from external APIs:
```ruby
# app/models/content/project.rb
class Content::Project < Perron::Resource
  source repos: {
    class: GitHubRepo,
    primary_key: :name,
    scope: -> (repos) { repos.select { it.language == "Ruby" } }
  }

  def self.source_template(source)
    <<~TEMPLATE
    ---
    title: #{source.repos.name}
    description: #{source.repos.description}
    language: #{source.repos.language}
    stars: #{source.repos.stargazers_count}
    repo_name: #{source.repos.name}
    ---

    # #{source.repos.name}

    #{source.repos.description}

    **Language:** #{source.repos.language}
    **Stars:** #{source.repos.stargazers_count}
    **URL:** #{source.repos.html_url}
    TEMPLATE
  end
end
```

```ruby
# app/models/git_hub_repo.rb
class GitHubRepo < ActiveResource::Base
  self.site = "https://api.github.com/"

  def self.all
    find(:all, from: "/users/Rails-Designer/repos")
  end
end
```

This will generate individual project pages for each repository (tagged "Ruby") with live GitHub data.


### Custom class requirements

Classes used with the `class` option must:

- implement an `.all` method that returns an enumerable collection
- return objects that respond to the specified primary_key method


### Use cases for API integration

Ideas for pulling from APIs are infinite. Here are some ideas:

**Content Generation:**
- product catalogs; pull from Shopify, WooCommerce APIs
- real estate listings; generate property pages from MLS data
- job boards; create job posting pages from recruitment APIs
- event listings; pull from Eventbrite, Meetup APIs

**Programmatic SEO:**
- location pages; "Service in [City]"
- comparison pages; "[Product] vs [Competitor]"
- industry pages; "[Tool] for [Industry]"
