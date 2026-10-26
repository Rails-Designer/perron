---
type: component
author: rails-designer
title: Search Form
description: A full-text search component using MiniSearch with keyboard navigation.
---
This web component provides instant full-text search powered by [MiniSearch](https://github.com/lucaong/minisearch). It features fuzzy matching, field boosting, grouped results and keyboard navigation. This template configures most for you, but there are a few manual steps to go through.


## Features

- **Instant search** with 150ms debounce
- **Fuzzy matching** handles typos automatically
- **Prefix search** finds "doc" when typing "documentation"
- **Keyboard navigation** with Arrow keys, Enter, and Escape
- **ARIA attributes** for accessibility (`aria-busy`)
- **Grouped results** by collection, category or any field
- **Highlighted matches** in titles and excerpts


Configure which collections are indexed in your initializer:
```ruby
# config/initializers/perron.rb
Perron.configure do |config|
  config.search_scope = %w[posts pages]
end
```

This includes all `posts` and `pages` in the search index.


Add fields to search per content type using `search_fields`:
```ruby
class Content::Post < Perron::Resource
  search_fields :description, :collection_name
end
```

These fields are added to the default search fields: `title`, `headings`, and `body`.


## Usage

```erb
<search-form data-endpoint="<%= search_path(trailing_slash: false) %>">
  <input type="search" placeholder="Search…" />

  <ul data-slot="results"></ul>
</search-form>
```

With empty state
```erb
<search-form
  data-endpoint="<%= search_path(trailing_slash: false) %>"
  data-empty="No results"
>
  <input type="search" placeholder="Search…" />

  <ul data-slot="results"></ul>

  <div data-slot="empty"></div>
</search-form>
```

With grouped results (you can group by any defined key):
```erb
<search-form
  data-endpoint="<%= search_path(trailing_slash: false) %>"
  data-group-by="collection_name"
>
  <input type="search" placeholder="Search…" />

  <ul data-slot="results"></ul>
</search-form>
```

With keyboard shortcut
```erb
<search-form
  data-endpoint="<%= search_path(trailing_slash: false) %>"
  data-shortcut="$mod+k"
>
  <input type="search" placeholder="Search…" />

  <ul data-slot="results"></ul>
</search-form>
```


## Configuration

### Attributes

| Attribute | Description |
|-----------|-------------|
| `data-endpoint` | URL to the search index JSON endpoint |
| `data-config` | JSON string with MiniSearch configuration |
| `data-empty` | Message to display when no results found |
| `data-group-by` | Field name to group results by |
| `data-shortcut` | Keyboard shortcut to focus the input |


### Data Config

Pass a JSON configuration object to customize search behavior:
```erb
<search-form
  data-endpoint="<%= search_path(trailing_slash: false) %>"
  data-config='{
    "fields": ["title", "headings", "body", "description"],
    "storeFields": ["title", "body", "href", "slug", "category"],
    "searchOptions": {
      "boost": {"title": 30, "category": 25, "description": 20},
      "prefix": true,
      "fuzzy": 0.2
    }
  }'
>
```


#### Fields (required)

Array of field names to search. Each field gets weighted equally by default.


#### Store Fields (required)

Array of field names to include in search results for rendering. **Must include `href`** for links to work.


#### Search Options

- `boost` - Increase weight for specific fields (higher = more relevant)
- `prefix` - Match partial words at the start (default: true)
- `fuzzy` - Allow typos (0-1, where 1 is most lenient; default: 0.2)
- `combineWith` - How to combine terms (`"AND"` or `"OR"`; default: `"AND"`)


## Styling

The component uses semantic data attributes for styling:

| Selector | Description |
|----------|-------------|
| `[data-slot="results"]` | Results container |
| `[data-slot="empty"]` | Empty state container |
| `[data-group-label]` | Group header text |
| `[data-result-link]` | Individual result link |
| `[data-result-title]` | Result title |
| `[data-result-excerpt]` | Result excerpt |
| `[data-selected]` | Currently selected item |


### State Attributes

| Attribute | When Set |
|-----------|----------|
| `data-open` | Results dropdown is visible |
| `data-focused` | Input has focus |
| `data-results` | Results are displayed |
| `data-empty` | No results found |
| `data-busy` | Loading search index |


### Example CSS

```css
search-form {
  position: relative;

  [data-slot="results"],
  [data-slot="empty"] {
    position: absolute;
    top: 100%;
    width: 100%;
    background: white;
    border: 1px solid #e2e8f0;
    border-radius: 0.375rem;
    box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  }

  [data-slot="results"] {
    display: grid;
    gap: 0.5rem;
    max-height: 24rem;
    overflow-y: auto;

    &:empty { display: none; }
  }

  [data-result-link] {
    display: block;
    padding: 0.5rem;
    text-decoration: none;

    &:hover,
    [data-selected] & {
      background: #f1f5f9;
    }
  }

  [data-result-title] {
    font-weight: 500;
    color: #0f172a;
  }

  [data-result-excerpt] {
    font-size: 0.875rem;
    color: #64748b;
  }

  mark {
    background: linear-gradient(to bottom right, #fecaca, #fed7aa);
    border-radius: 0.125rem 0.5rem 0.5rem 0.125rem;
  }
}
```