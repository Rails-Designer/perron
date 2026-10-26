---
section: render
position: 2
title: Rendering & filtering
description: Perron's resources are just Ruby objects so it is straight-forward to select, filter and order resources.
---

Perron's resources are just Ruby objects so it is straight-forward to render, filter and order resources.


## Resource content

To render a resource's content, use `@resource.content`.
```erb
<%= @resource.content %>
```

## Rendering resources

Render a list of resources with: `Content::Post.all`. Pass the array to `render`, just like with ActiveRecord models:
```erb
<%= render Content::Post.all %>
```

This expects a partial `app/views/content/posts/_post.html.erb`.

Or set a partial and pass the collection:
```erb
<%= render partial: "content/posts/snippet", collection: Content::Post.all %>
```

## ActiveRecord-style queries

Perron supports familiar ActiveRecord-style query methods for cleaner, more readable code.


### Where

Filter resources using hash syntax:
```ruby
Content::Post.where(category: "ruby")
Content::Post.where(published: true)
Content::Post.where(section: [:content, :metadata])
```


### Order

Sort resources by attributes:
```ruby
Content::Post.order(:title)
Content::Post.order(:publication_date, :desc)
Content::Post.order(title: :desc)
```


### Limit

Limit the number of results:
```ruby
Content::Post.limit(5)
Content::Post.order(:publication_date, :desc).limit(3)
```

### Offset

Offset the number of results:
```ruby
Content::Post.offset(2)
Content::Post.offset(2).limit(5)
```


### in_order_of

Preserve a custom sort order by specifying field values:

```ruby
Content::Post.in_order_of(:category, %w[featured popular recent])
Content::Post.in_order_of(:category, %w[featured popular], filter: false)
```

By default, resources not matching the given values are excluded. Pass `filter: false` to keep them (appended after the ordered set).


### Scopes

Define reusable query scopes:
```ruby
class Content::Post < Perron::Resource
  scope :getting_started, -> { where(section: :getting_started) }
  scope :recent, -> { order(:publication_date, :desc).limit(10) }
end

Content::Post.getting_started.order(:title).limit(5)
```


### Chaining

Chain methods together for complex queries:
```ruby
Content::Post
  .where(published: true)
  .order(:publication_date, :desc)
  .limit(5)
```


## Enumerable methods

All standard Ruby enumerable methods are available: `select`, `reject`, `map`, `find`, `group_by`, `sort_by`, `count`, `any?`, `all?`, `first`, `last` and more.

```ruby
Content::Post.all.select { it.published? }
Content::Post.all.group_by(&:category)
Content::Post.all.sort_by(&:publication_date).reverse
```
