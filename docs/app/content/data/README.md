# Data

Perron can consume structured data from YML, JSON or CSV files, making them available within your templates. This is useful for populating features, team members or any other repeated data structure.


## Usage

Access data resources using the `Content::Data` namespace with the class name matching your file's basename:
```erb
<% Content::Data::Features.all.each do |feature| %>
  <h4><%= feature.name %></h4>
  <p><%= feature.description %></p>
<% end %>
```

Look up one `record` with `Content::Data::Features.find("feature-id")`.


## File location and formats

By default, Perron looks up `app/content/data/` for files with a `.yml`, `.json` or `.csv` extension. For a `features` call, it would find `features.yml`, `features.json` or `features.csv`. You can also provide a path to any data resource, via `Perron::Data.new("path/to/data.json")`.


## Accessing data

The wrapper object provides flexible, read-only access to each record's attributes. Both dot notation and hash-like key access are supported.
```ruby
feature.name
feature[:name]
```


## Rendering

You can render data collections directly using Rails-like partial rendering. When you call `render` on a data collection, Perron will automatically render a partial for each item.
```erb
<%= render Content::Data::Features.all %>
```

This expects a partial at `app/views/content/features/_feature.html.erb` that will be rendered once for each feature in your data resource. The individual record is made available as a local variable matching the singular form of the collection name.
```erb
<!-- app/views/content/features/_feature.html.erb -->
<div class="feature">
  <h4><%= feature.name %></h4>
  <p><%= feature.description %></p>
</div>
```


## Data structure

Data resources must contain an array of objects. Each record should include an `id` field if you plan to use it in [associations](/docs/resources/#associations):
```yaml
# app/content/data/authors.yml
- id: rails-designer
  name: Rails Designer
  bio: Creator of Perron

- id: cam
  name: Cam
  bio: Contributing author
```
