---
section: content
position: 3
title: Generator
description: Use Perron's generator to easily create new collections and content files.
---

Create a new collection using the built-in generator:
```bash
bin/rails generate content Post
```

This will create the following files:

* `app/content/posts/` (all `.md`, `.erb` content will be added here)
* `app/models/content/post.rb`
* `app/controllers/content/posts_controller.rb`
* `app/views/content/posts/index.html.erb`
* `app/views/content/posts/show.html.erb`

And adds a route: `resources :posts, module: :content, only: %w[index show]`

> [!note]
> View all available commands with `bin/rails generate content --help`

Create the only needed action with:
```bash
bin/rails generate content Post show
```


## Inline content

Use `--inline` to generate a show action that does not need a `show.html.erb` template because the resource has all the needed HTML. It will create a show action like this:
```erb
def show
  @resource = Content::Post.find!(params[:id])

  render @resource.inline
end
```

This is useful for resources that do not need shared HTML as a `show.html.erb` provides.


## Creating new content files

Once a collection is created, quickly generate new content files:
```bash
bin/rails generate content Post --new
bin/rails generate content Post --new "My First Post"
```

This creates a new file in `app/content/posts/` based on a template (if one exists).


### Using templates

Drop a template file in the content directory to define the structure for new files:

```erb
---
title: <%= @title %>
published_at: <%= Time.current %>
---

# <%= @title %>

Start writing here…
```

If no template exists, an empty file with frontmatter dashes is created.

Template filenames support `strftime` parameters for dynamic naming, when respectively a title (eg. `My First Post`) and no title is passed:

- `template.md.tt`; generates `my-first-post.md` and `untitled.md`
- `%Y-%m-%d-template.md.tt`; generates `2026-01-01-my-first-post.md` and `2026-01-01-untitled.md`
