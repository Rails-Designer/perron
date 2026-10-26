---
section: render
position: 2.5
title: Pagination
description: Paginate resources across multiple pages with simple helpers.
---

Pagination splits large collections across multiple pages, each limited to a configurable number of items.

## Configuration

Set the number of items per page in the resource class:
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  configure do |config|
    config.pagination.per_page = 10
  end
end
```


## Controller

Include `Perron::PaginateHelper` and call `paginate` with the resource class and a collection:
```ruby
# app/controllers/content/posts_controller.rb
class Content::PostsController < ApplicationController
  include Perron::PaginateHelper

  def index
    @paginate, @resources = paginate(Content::Post.all)
  end
end
```

`paginate` returns two values: a paginate object and the page's resource collection.

The paginate object is available as `@paginate` in your views.


## Views

Link to previous and next pages:
```erb
<%# app/views/content/posts/index.html.erb %>
<%= link_to "Previous", @paginate.previous if @paginate.previous? %>
<%= link_to "Next", @paginate.next if @paginate.next? %>
```

The paginate object provides these methods:

| Method | Description |
| :----- | :---------- |
| `previous` | Returns the path for the previous page |
| `previous?` | Returns `true` if a previous page exists |
| `next` | Returns the path for the next page |
| `next?` | Returns `true` if a next page exists |
