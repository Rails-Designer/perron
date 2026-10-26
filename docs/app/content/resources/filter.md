---
type: component
author: rails-designer
title: Filter Items
description: A web component for filtering lists of items based on checkbox or radio inputs.
---
This web component filters a list of items based on form inputs (checkboxes or radio buttons). Items are shown or hidden by matching their `data-*` attributes against the selected form values.


## Features

- **Multi-value filtering** - Items can match multiple categories (comma-separated)
- **Match modes** - Filter by "any" (OR) or "all" (AND) selected values
- **Exclusion** - Mark items to exclude from filtering entirely
- **Empty state** - Display a message when no items match
- **Count tracking** - Form attributes track total and filtered counts
- **Event API** - Listen to `filterchange` events for custom behavior


## Usage

Basic usage with checkboxes:
```erb
<form id="filters">
  <label><input type="checkbox" name="category" value="code"> Code</label>

  <label><input type="checkbox" name="category" value="product"> Product</label>
</form>

<filter-items form="filters">
  <span data-category="code">Gem install guide</span>

  <span data-category="product">Pro plan</span>
</filter-items>
```

With empty state:
```erb
<filter-items form="filters">
  <span data-category="code">Gem install guide</span>
  <span data-category="product">Pro plan</span>

  <p data-empty-state hidden>No items match your filters</p>
</filter-items>
```

Multi-category items (comma-separated values):
```erb
<filter-items form="filters">
  <span data-category="code,tutorial">Rails tips</span>

  <span data-category="product,design">Pro resources</span>
</filter-items>
```


## Attributes

| Attribute | Description |
|-----------|-------------|
| `form` | ID of the form containing filter inputs |
| `mode` | Match mode: `"any"` (OR) or `"all"` (AND) |


## Data Attributes on Items

Items use `data-*` attributes where `*` matches the `name` attribute on form inputs:
```html
<span data-category="code,tutorial">Rails tips</span>
```

| Attribute | Purpose |
|-----------|---------|
| `data-{name}` | Values to filter by (comma-separated) |
| `data-empty-state` | Marks the empty state element |
| `data-filter-exclude` | Excludes item from filtering |


## Form Count Attributes

The form element receives count attributes for each filter type:
```html
<form id="filters" category-total-count="10" category-filtered-count="3">
```

## Events

Listen to `filterchange` for custom behavior:
```javascript
document.querySelector("filter-items").addEventListener("filterchange", (event) => {
  console.log("Visible:", event.detail.visibleCount)
  console.log("Total:", event.detail.totalCount)
})
```