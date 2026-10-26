---
section: content
position: 1
title: Resources
description: Resources are a collection of similar content and resources, like posts, articles or people.
---

Perron is, just like Rails, designed with convention over configuration in mind.

All content is stored in `app/content/*/*.{erb,md,*}` and backed by a class, located in `app/models/content/` that inherits from `Perron::Resource`.

The controllers are located in `app/controllers/content/`. To make them available, create a route: `resources :posts, module: :content, only: %w[index show]`.


## Resource class

Every resource class inherits from `Perron::Resource`, e.g.:
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
end
```

This gives each class its base behavior. It is just a regular Ruby class, so all common methods are available:
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  delegate :title, to: :metadata

  def loud_category
    metadata.category.upcase
  end
end
```


## Associations

Resources can be associated with each other using `has_many` and `belongs_to`, similar to ActiveRecord associations.


### has_many

Define a `has_many` association to retrieve all resources that belong to the current resource:
```ruby
# app/models/content/author.rb
class Content::Author < Perron::Resource
  has_many :posts
end
```

```markdown
<!-- app/content/authors/rails-designer.md -->
---
name: Rails Designer
bio: Creator of Perron
---

What could I say? I create lots of things? Like Perron, for example! 😊
```

Access the collection:
```ruby
author = Content::Author.find("rails-designer")
author.posts # => Array of Content::Post instances where author_id matches
```

### belongs_to

Define a `belongs_to` association when a resource references another resource:
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  belongs_to :author
  belongs_to :editor, class_name: "Content::Author"
end
```

In the content's frontmatter, add the association name with `_id` suffix:
```markdown
<!-- app/content/posts/my-first-post.md -->
---
title: My First Post
author_id: rails-designer
editor_id: cam
---

Post content here…
```

Access the associated resource:
```ruby
post = Content::Post.find("my-first-post")
post.author # => Content::Author instance
post.editor # => Content::Author instance
```


### Associations with Data sources

Associate resources with [data sources](/docs/data/) using the `class_name` option. This works for both `belongs_to` and `has_many` associations.


#### belongs_to with Data

```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  belongs_to :editor, class_name: "Content::Data::Editors"
end
```

```yaml
# app/content/data/editors.yml
- id: kendall
  name: Kendall
  bio: Master of the edit

- id: chris
  name: Chris
  bio: Editor Overlord
```

```markdown
<!-- app/content/posts/my-first-post.md -->
---
title: My First Post
editor_id: kendall
---

Post content here…
```

The association works the same way as with Content resources, but pulls data from the structured data resource.


#### has_many with Data

For multiple associations, use an array of IDs in the frontmatter. This pattern mimics Rails' `has_and_belongs_to_many` associations, where the relationship is defined by a list of IDs:
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  has_many :editors, class_name: "Content::Data::Editors"
end
```

```markdown
<!-- app/content/posts/my-first-post.md -->
---
title: My First Post
editor_ids: [kendall, chris]
---

Post content here…
```

Access the collection:
```ruby
post = Content::Post.find("my-first-post")
post.editors # => Array of Content::Data::Editor instances where id matches editor_id
```

When `{association_name}_ids` is present in the frontmatter, Perron uses those IDs to find the associated records. If not present, it falls back to foreign key matching (e.g., looking for `post_id` in the data records).


## Adjacency (next/previous)

Resources can navigate to adjacent resources (next/previous) in the collection:

```erb
<%= link_to "Previous", @resource.previous, rel: "prev" if @resource.previous %>

<%= link_to "Next", @resource.next, rel: "next" if @resource.next %>
```

By default, adjacency uses the collection's default order (id). Configure your preferred ordering:
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  adjacent_by :position

  delegate :position, to: :metadata
end
```

You can also traverse cross-group by passing `within`:
```ruby
class Content::Post < Perron::Resource
  adjacent_by :position, within: :category

  delegate :position, to: :metadata, :category
end
```

This assumes resources are grouped/connected through a category.

Or if categories are in a specific order, configure as:
```ruby
class Content::Post < Perron::Resource
  adjacent_by :position, within: { category: %w[getting_started content metadata] }

  delegate :position, to: :metadata, :category
end
```


## Validations

Validate values from resource classes, the frontmatter for example:
```ruby
class Content::Post < Perron::Resource
  CATEGORIES = %w[rails ruby hotwire javascript updates]

  delegate :category, :title, :description, to: :metadata

  validates :title, :description, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  # …
end
```

Perron offers a `bin/rails perron:validate` task that runs all validations and outputs any failures. Useful to check if the title or meta description is within the correct range for SERP's or to make sure the correct category is added. To validate frontmatter, make them callable in the class, as seen above using `delegate`.

Validation output could look something like this:
```console
rails perron:validate
..........................F.....
Resource: /perron/docs/app/content/articles/resources.md
  - Description can't be blank

Validation finished with 1 failure.
```

> [!tip]
> When using Rails 8.1, make Perron's validate task part of the `bin/ci` script. Simply add `step "Perron: validate", "bin/rails perron:validate"` within the `CI.run do` block.


## `@resource` instance

In a `show` action, a resource instance variable is expected to be set.
```ruby
class Content::PostsController < ApplicationController
  def show
    @resource = Content::Post.find!(params[:id])
  end
end
```

> [!important]
> Various features from Perron rely on @resource instance variable being available.


## Inline rendering

Use `@resource.inline` to render content without a view template. This is useful when your controller only needs to render the resource's content:
```ruby
class Content::PostsController < ApplicationController
  def show
    @resource = Content::Post.find(params[:id])

    render @resource.inline
  end
end
```


## Setting a root page

To set a root page, create a `root.{md,erb}` file in the pages content directory (`app/content/pages/root.erb`) and add a `root` action in `Content::PagesController`:
```ruby
# app/controllers/content/pages_controller.rb
class Content::PagesController < ApplicationController
  def root
    @resource = Content::Page.root

    render :show
  end
end
```

Then add the root route to `config/routes.rb`:
```ruby
root to: "content/pages#root"
```

This is automatically generated when generating a `Page` collection using the [content generator](/docs/generator/). Opt out by passing `--no-include-root`:
```bash
rails generate content Page --no-include-root
```


## Destroy

Delete resource content files programmatically:
```ruby
Content::Post.find("slug").destroy  # deletes app/content/posts/slug.md
Content::Post.destroy_all  # deletes app/content/posts/*.{ext}
```


## Custom collection name

When your route resource name doesn't match your collection name, define a custom collection name:

```ruby
# app/controllers/content/saas_posts_controller.rb
class Content::SaasPostsController < ApplicationController
  # Route is `resources :saas_posts` but collection is "posts"
  def self.collection_name = "posts"

  def index
    @resources = Content::Post.all
  end
end
```

Perron checks for this method first before falling back to deriving the collection name from the controller name.
