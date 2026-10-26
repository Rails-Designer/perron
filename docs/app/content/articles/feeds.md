---
section: meta
position: 9
title: Feeds
description: Perron can create RSS, Atom and JSON feeds from collections.
---

Perron can create RSS, Atom and JSON feeds of collections.

The `feeds` helper automatically generates HTML `<link>` tags for generated feeds.


## Usage

In the layout (e.g., `app/views/layouts/application.html.erb`), add the helper to the `<head>` section:
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

Similarly, exclude collections with:
```erb
<%= feeds except: %w[pages] %>
```


## Configuration

Feeds are configured in the `Resource`'s collection:
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  configure do |config|
    config.feeds.atom.enabled = true
    # config.feeds.atom.title = "My Atom feed"
    # config.feeds.atom.description = "My Atom feed description"
    # config.feeds.atom.path = "posts.atom"
    # config.feeds.atom.max_items = 25

    config.feeds.json.enabled = true
    # config.feeds.json.title = "My JSON feed" # defaults to configured site_name
    # config.feeds.json.description = "My JSON feed description" # defaults to configured site_description
    # config.feeds.json.max_items = 15
    # config.feeds.json.path = "posts.json"
    # config.feeds.json.ref = "json-feed" # adds `?ref=json-feed` to item links for tracking

    config.feeds.rss.enabled = true
    # config.feeds.rss.title = "My RSS feed" # defaults to configured site_name
    # config.feeds.rss.description = "My RSS feed description" # defaults to configured site_description
    # config.feeds.rss.path = "posts.rss"
    # config.feeds.rss.max_items = 25
    # config.feeds.rss.ref = "rss-feed" # adds `?ref=rss-feed` to item links for tracking
  end
end
```


## Author

Feeds can include optional author information. Set a default author for the collection:

```ruby
class Content::Post < Perron::Resource
  configure do |config|
    config.feeds.atom.author = {
      name: "Rails Designer",
      email: "support@railsdesigner.com"
    }

    config.feeds.json.author = {
      name: "Rails Designer",
      email: "support@railsdesigner.com"
    }

    config.feeds.rss.author = {
      name: "Rails Designer",
      email: "support@railsdesigner.com"
    }
  end
end
```

Individual resources can override this using a [`belongs_to :author` relationship](/docs/resources/#associations):

```ruby
class Content::Post < Perron::Resource
  belongs_to :author
end
```

```markdown
---
title: My Post
author_id: kendall
---
```

> [!NOTE]
> RSS and Atom feeds require an email address. JSON feeds only require a name. All support optional `url` and `avatar` fields.


### Using a data resource

Prefer to manage authors in a [data resource](/docs/data/) instead of individual content resources, create a YAML file in `app/content/data/`, e.g., `app/content/data/authors.yml` or `app/content/data/team.yml`:

```yaml
- id: kendall
  name: Kendall
  email: kendall@railsdesigner.com
  url: https://example.com
  avatar: /images/kendall.jpg
  bio: Software developer and writer
  myspace: kendall-rd
```

> [!note]
> For feeds to work, data must include at least `name` and `email` keys (or just `name` for JSON feeds).

Then add the `class_name` option to the `belongs_to` association:

```ruby
class Content::Post < Perron::Resource
  belongs_to :author, class_name: "Content::Data::Authors"
end
```


## Custom templates

Override the default feed templates by creating custom views. Place them in `app/views/content/{collection_name}/`:

- `rss.erb`
- `atom.erb`
- `json.erb`

The builder provides access to:

- `collection`; the collection object
- `resources`; the actual resource items (to iterate over)
- `config`; the feed configuration

Example `app/views/content/posts/json.erb`:
```erb
{
  "version": "https://jsonfeed.org/version/1",
  "title": "<%= config.title || collection.name %>",
  "items": <%= resources.map { |resource| {
    id: resource.id,
    title: resource.metadata.title,
    url: "/posts/#{resource.slug}",
    content_html: resource.content
  }}.to_json %>
}
```
