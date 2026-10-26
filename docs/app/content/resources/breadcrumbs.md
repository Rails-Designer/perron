---
type: component
author: rails-designer
title: Breadcrumbs
description: A breadcrumb navigation system using a concern and partial.
---
This headless component provides breadcrumb navigation. It uses a concern to add breadcrumb functionality to controllers and includes proper ARIA attributes and JSON-LD structured data for accessibility and SEO.

The breadcrumbs can be set in controllers using an explicit array-based approach. The system includes a `Breadcrumb` class that handles both linked and non-linked breadcrumb items.

Usage in controllers:
```ruby
class Content::PostsController < ApplicationController
  def show
    @resource = Content::Post.find!(params[:id])

    set_breadcrumbs(
      ["Blog", posts_path],
      [@resource.title]
    )
  end
end
```

In your layout or views:
```erb
<%= render "shared/breadcrumbs" %>
```