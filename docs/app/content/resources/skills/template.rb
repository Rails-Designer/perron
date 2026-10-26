gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  create_file "SKILL.md", <<~'TEXT', force: true
---
name: perron
description: Build static sites with Perron, a Rails-based static site generator. Use this skill when the user mentions Perron or SSG in Rails, when the perron gem is available or when `config/initializers/perron.rb` is available.
triggers:
  - perron
  - ssg
  - static site
  - static site generator
  - website
invocable: true
---

Perron is a Rails-based Static Site Generator (SSG). Build with Rails. Deploy static sites.

## Core Concepts

- **Build time ≠ request time** - `rails perron:build` generates static HTML for deployment
- **Content files ARE models** - no database, no ActiveRecord; content lives in `app/content/{collection}/`
- **Development vs Production** - use `bin/dev` or `rails server` for local development; use `rails perron:build` for production (generates static files)
- **Feeds and sitemaps** - only generated during `perron:build`, not in development
- **Rails Engine** - Perron is a Rails engine that extends your app

## Content Collections

Content is organized in collections under `app/content/`:

```
app/content/
├── pages/
│   ├── root.erb       # Special: becomes "/" (homepage)
│   ├── about.md       # Becomes "/about/"
│   └── 2024-01-15-my-page.md  # Date prefix stripped from slug
├── posts/
│   ├── 2024-01-15-welcome.md  # Becomes "/posts/welcome/"
│   └── 2024-01-16-another-post.md
└── data/
    └── authors.yml    # Static data accessible via Content::Data::Authors
```


## Image Assets

Place static assets (images, etc.) in the `public/` folder:

```
public/
└── images/
    └── og-default.jpg
```

Reference them in frontmatter as `/images/og-default.jpg` — they will be copied to the output during build.


## Routing

Perron controllers live in the `content/` module. Use standard Rails routing with path overrides:

```ruby
Rails.application.routes.draw do
  root to: "content/pages#root"

  resources :articles, path: "docs", module: :content, only: %%w[index show] do
    get ":id.md", to: "articles/markdown#show", as: :markdown, on: :collection
  end

  resources :categories, module: :content, path: "library/category", constraints: { id: /#{Content::Resource::TYPES.keys.join("|")}/ }, only: %%w[show]

  resources :resources, module: :content, path: "library", only: %%w[index show] do
    resource :template, path: "template.rb", module: :resources, only: %%w[show] # IMPORTANT: the nested resource (controller, views, etc.) needs to be in correct namespace, eg. `app/controllers/content/resources/template_controller.rb`
  end
end
```

### Collection Name Override

Override the collection name on a controller to reuse an existing collection:

```ruby
class Content::MembersController < ApplicationController
  def self.collection_name = "pages"

  def show
  end
end
```

Now files in `app/content/pages/` can be rendered via `/team/:id`:

```ruby
resources :members, module: :content, path: "team", constraints: { id: /cam|kendall|chris/ }, only: %%w[show]
```

## AR-Style Relations

Perron provides ActiveRecord-style query methods via `Perron::Relation`. **Not full AR parity** — these are the supported methods:

```ruby
# Class-level queries (returns Perron::Relation)
Content::Post.all
Content::Post.where(slug: "my-post")
Content::Post.where(author: ["alice", "bob"]) # OR logic
Content::Post.where(draft: false)
Content::Post.order(:published_at, :desc)
Content::Post.order(published_at: :desc) # hash syntax
Content::Post.limit(10)
Content::Post.offset(5)
Content::Post.first(5) # returns array of 5
Content::Post.last # single resource
Content::Post.pluck(:slug, :title) # returns [[slug1, title1], ...]

# Find by id (raises if not found — like Rails)
Content::Post.find(params[:id])
Content::Post.find!("slug-here") # raises RecordNotFound, used in generated controllers

# Chaining
Content::Post.where(draft: false).order(:published_at).limit(5)
```

### Custom Scopes

Define scopes in your Content model as lambdas:

```ruby
class Content::Post < Perron::Resource
  scope :published, -> { where(draft: false) }
  scope :recent, -> { order(:published_at, :desc).limit(10) }
  scope :by_author, ->(name) { where(author: name) }
end

Content::Post.published.recent
Content::Post.published.by_author("alice")
```

## Views

### @resource Convention

Set `@resource` yourself in your controller — the generator adds this, but the variable **must be named `@resource`** (not `@post`, `@article`, etc.) since various Perron features rely on it:

```ruby
class Content::PostsController < ApplicationController
  def show
    @resource = Content::Post.find(params[:id])
  end

  def index
    @resources = Content::Post.all
  end
end
```

Then use it in views:

```erb
<%%# app/views/content/posts/show.html.erb %%>
<h1><%%= @resource.metadata.title %%></h1>
<%%= markdownify @resource.content %%>

<%%# app/views/content/posts/index.html.erb %%>
<%%= render @resources %%>

<%%# app/views/content/posts/_post.html.erb %%>
<article>
  <h2><%%= post.metadata.title %%></h2>
</article>
```

## View Helpers

### meta_tags

Renders SEO meta tags. **Do NOT write raw `<meta>` tags** — use this helper:

```erb
<%%= meta_tags %%>
<%%= meta_tags only: [:title, :description] %%>
<%%= meta_tags except: [:image] %%>
```

Available options: `title`, `description`, `image`, `url`, `type`, `site_name`, `published_time`, `modified_time`, `author`

### feeds

Renders feed link tags. Feeds are only generated during `perron:build`, not in development:

```erb
<%%= feeds %%>
<%%= feeds formats: %%w[rss atom] %%>
```

Override default feed templates by creating `app/views/content/{collection}/{rss,atom,json}.erb`:

```erb
<%%# app/views/content/posts/json.erb %%>
{
  "version": "https://jsonfeed.org/version/1",
  "title": "<%%= config.title || collection.name %%>",
  "items": <%%= resources.map { |resource| {
    id: resource.id,
    title: resource.metadata.title,
    url: "/posts/#{resource.slug}",
    content_html: resource.content
  }}.to_json %%>
}
```

Templates have access to: `collection`, `resources`, `config`

### markdownify

Renders markdown content:

```erb
<%%= markdownify @resource.content %%>
<%%= markdownify @resource.content, process: %%w[absolute_urls lazy_load_images] %%>
```

Available processors: `absolute_urls`, `lazy_load_images`, `target_blank`

Custom processors go in `app/processors/` (or any loadable location):

```ruby
# app/processors/add_nofollow_processor.rb
class AddNofollowProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("a[target=_blank]").each { |it| it["rel"] = "nofollow" }
  end
end
```

```erb
<%%= markdownify @resource.content, process: ["absolute_urls", AddNofollowProcessor] %%>
```

### erbify

Embed ERB in markdown content:

```erb
<%%= erbify do %%>
  The current page slug is: <%%= @resource.slug %%>
<%% end %%>
```

## Frontmatter

Each content file supports YAML frontmatter:

```yaml
---
title: My Post Title
description: SEO description for this page
image: /images/og-default.jpg
author_id: alice # Used by belongs_to associations
published_at: 2024-01-15 # Overrides filename date; future dates = scheduled
draft: true # Excluded from production build
preview: true # Adds obscured token to slug
preview: secret # Adds "-secret" to slug (predictable suffix)
---
```

### Meta Tag Options

Use these keys in frontmatter for meta_tags helper:

| Key | Meta tag |
|-----|----------|
| `title` | `<title>` and `og:title` |
| `description` | `description` and `og:description` |
| `image` | `og:image` |
| `url` | `og:url` |
| `type` | `og:type` |
| `site_name` | `og:site_name` |
| `published_at` | `article:published_time` |
| `updated_at` | `article:modified_time` |
| `author` | `article:author` |

### Publication States

- `draft: true` or `published: false` → draft
- `published_at` in the future → scheduled
- In development, drafts and scheduled content ARE shown
- In production build, they are excluded

### Preview URLs

`preview: true` adds an obscured token to the slug (e.g., `/posts/welcome-a3f8b2`). Use `preview: secret` to add a predictable suffix (`/posts/welcome-secret`). Share these URLs to preview drafts or scheduled content without deploying.

## Static Data (Content::Data)

Files in `app/content/data/` become data classes. The `id` field is only required if you plan to use `.find`:

```ruby
# app/content/data/authors.yml
# - id: alice
#   name: Alice Smith
#   role: editor

Content::Data::Authors.all
Content::Data::Authors.find("alice") # requires id field
Content::Data::Authors.first
```

You can iterate or loop over data without an `id` field.

## Associations

Define in your Content model. Use `class_name` with `Content::Data::*` prefix to reference data content:

```ruby
class Content::Post < Perron::Resource
  belongs_to :author, class_name: "Content::Data::Authors"
  has_many :comments
end
```

Perron looks for `author_id` or `comment_ids` in frontmatter and resolves them against the associated class.

## Programmatic Content (Sources)

### Lambda Filtering

Filter source items with a lambda:

```ruby
class Content::Product
  sources :countries, products: -> (products) { products.select(&:featured?) }
end
```

### External API Sources

Pull data from external APIs by implementing a class that responds to `.all`. How you interact with the API is up to you. Here's an example using the [ActiveResource gem](https://github.com/rails/activeresource):

```ruby
class GitHubRepo < ActiveResource::Base
  self.site = "https://api.github.com/"

  def self.all
    find(:all, from: "/users/Rails-Designer/repos", params: { per_page: 5 })
  end
end

class Content::Project < Perron::Resource
  sources repos: { class: GitHubRepo, primary_key: :name }

  def self.source_template(source)
    <<~TEMPLATE
    ---
    title: #{source.repos.name}
    description: #{source.repos.description}
    language: #{source.repos.language}
    stars: #{source.repos.stargazers_count}
    ---

    #{source.repos.description}
    TEMPLATE
  end
end
```

Your class just needs to respond to `.all` and return objects matching the `primary_key`.

## Content Generators

Use `rails g content Post --new` to generate a template. Filename strftime patterns create dated files:

| Pattern | Example output |
|---------|---------------|
| `%%s-template.md.tt` | `1709337600-my-post.md` |
| `%%Y-%%m-%%d-template.md.tt` | `2026-03-02-my-post.md` |
| `%%d-template.md.tt` | `02-my-post.md` |

Every [strftime specifier](https://docs.ruby-lang.org/en/master/language/strftime_formatting_rdoc.html) is supported.

## Configuration

```ruby
# config/initializers/perron.rb
Perron.configure do |config|
  config.mode = :standalone # :standalone (default) or :integrated
  config.output = "output"
  config.live_reload = true
  config.site_name = "My Site"
  config.markdown_parser = :commonmarker # only needed if you want to use your own Markdown parser, otherwise auto-picked from: commonmarker, kramdown, redcarpet
end
```

By default no markdown gem is added to your Gemfile. Perron auto-detects which one is installed.

### Modes

Choose one mode:

- **standalone** (default) - outputs a complete static site in `/output/`. Deploy the output folder.
- **integrated** - creates static pages in `/public/` alongside an otherwise normal Rails app.

### Environment Variables

`VIEW_UNPUBLISHED=true` shows drafts and scheduled content without editing the initializer.

## Rake Tasks

| Task | Purpose |
|------|---------|
| `bin/rails perron:install` | Sets up Perron in a Rails app |
| `rails perron:build` | Generates static HTML. Run in `RAILS_ENV=production`. For deployment. |
| `rails perron:clobber` | Removes compiled static output |
| `rails perron:validate` | Validates all site resources |
| `rails perron:sync_sources` | Generates files from programmatic content sources |

When an output folder exists (from a previous build), `bin/dev` or `rails server` serves it directly. Useful to verify what will be deployed. Run `rails perron:clobber` to remove it.


## Library

The docs site at [perron.railsdesigner.com/library/](https://perron.railsdesigner.com/library/) contains copy-pasteable components and snippets using Rails' template feature.

TEXT

  %%w[.opencode .claude .gemini].each do |folder|
    destination = File.join(folder, "skills/perron")

    if File.directory?(File.join(destination_root, folder))
      FileUtils.mkdir_p(File.join(destination_root, destination))

      copy_file "#{__dir__}/../SKILL.md", File.join(destination, "SKILL.md")

      say "Add Perron skill for #{folder.delete_prefix(".").humanize}"
    end
  end
end
