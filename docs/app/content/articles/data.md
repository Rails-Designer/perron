---
section: content
position: 2
title: Data sources
description: Perron can consume data files like yaml, json and CSV.
---

Perron can consume structured data from YML, JSON or CSV files, making them available within views. This is useful for populating features, team members or any other repeated data structure.


## Usage

Access data sources using the `Content::Data` namespace with the class name matching the file's basename:
```erb
<% Content::Data::Features.all.each do |feature| %>
  <h4><%= feature.name %></h4>

  <p><%= feature.description %></p>
<% end %>
```


## File location and formats

By default, Perron looks up `app/content/data/` for files with a `.yml`, `.json` or `.csv` extension. For `Features`, it would find `features.yml`, `features.json` or `features.csv`. Provide a path to any data resource in `/app/content/data/`, via `Content::Data.new("path/to/data-resource")`.


## Accessing data

The wrapper object provides flexible, read-only access to each record's attributes. Both dot notation and hash-like key access are supported.
```ruby
feature.name
feature[:name]
```


## Rendering

Render data collections directly using Rails-like partial rendering:
```erb
<%= render Content::Data::Features.all %>
```

This expects a partial at `app/views/content/features/_feature.html.erb` that will be rendered once for each item in `Content::Data::Features.all`. The individual record is made available as a local variable matching the singular form of the collection name.
```erb
<!-- app/views/content/features/_feature.html.erb -->
<div class="feature">
  <h4><%= feature.name %></h4>

  <p><%= feature.description %></p>
</div>
```


## Data structure

Data resources must contain an array of objects. Each record should include an `id` field if used with [associations](/docs/resources/#associations) or with the `find` method:
```yaml
# app/content/data/authors.yml
- id: rails-designer
  name: Rails Designer
  bio: Creator of Perron

- id: cam
  name: Cam
  bio: Contributing author
```

Look up a single entry with `Content::Data::Features.find("advanced-search")`, where `"advanced-search"` matches the value of the entry's `id` field.

A flat array is accepted as well:
```yaml
- Custom design based on our templates
- Copywriting services
- Dedicated project manager
```


## Enumerable methods

All data objects support enumerable methods like `select`, `sort_by`, `first` and `count`. See [Enumerable methods](/docs/rendering/#enumerable-methods) for the full list of available methods.


## Caching

Data sources can be cached if you are dealing with large files (mutliple thousands of rows). This is especially useful where you dynamically uses data sources instead of creating resources.

Enable by adding `config.cache_data_sources = false` to your Perron initializer.
