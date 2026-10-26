---
section: render
position: 4
title: Publishing
description: Control the visibility of content by marking it as published, scheduled or draft.
erb: true
---

Perron includes a system for managing the publication status of content resources. This allows creating drafts, publish content immediately or schedule it to be published in the future.

This status is determined by looking at the resource's frontmatter or, as a fallback, the date in its filename.


## Setting the Publication Date

There are two ways to define when a piece of content should be considered published. Perron uses the first valid date it finds, checking in this order:


### Frontmatter (Recommended)

Set a `published_at` key in the resource's frontmatter. This gives precise control over the publication time. The value should be a valid date or datetime string. Examples:
* Date only: `<%= Time.current.yesterday.to_date %>`
* Date with time: `<%= Time.current.yesterday.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S") %>`
* ISO 8601 with timezone: `<%= Time.current.yesterday.beginning_of_day.iso8601 %>`

```yaml
---
title: My Scheduled Post
published_at: <%= Time.current.yesterday.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S") %>
---
```

> [!note]
> If `published_at` is set to a time in the future, the content is considered **scheduled**.


### Filename

If `published_at` is not set in the frontmatter, Perron will attempt to parse a date from the resource's filename. The filename must be prefixed with a date in the format `YYYY-MM-DD-`.

For a file named `<%= Time.current.yesterday.strftime("%Y-%m-%d") %>-my-first-post.md`, the publication date will be set to the beginning of that day.


## Drafts

To prevent a resource from being published, mark it as draft. This is useful for content that is not yet ready. There are two ways to do this in the frontmatter:
```yaml
---
title: This is a Work in Progress
draft: true
---
```

Alternatively, use `published: false`:
```yaml
---
title: Another Work in Progress
published: false
---
```

> [!note]
> A resource will not be published if `draft` is `true`, if `published` is `false` or if its publication date is in the future.


## Preview

Set `preview: true` frontmatter to allow draft or scheduled content to be built in production with a secret token appended to the slug.

Examples:
```yml
preview: true # → "my-post-a1b2c3d4e5f6"
preview: custom-token # → "my-post-custom-token"
```

The generated token is built off the content's file path. So if the file path changes, the generated token will change too.

Note that anyone with the “secret link” can view the content, including (search) bots. To skip indexing, by decent bots, of “previewable resources” add this to the `<head>`:
```erb
<%% if @resource.preview? %>
  <meta name="robots" content="nofollow, noindex" />
<%% end %>
```


## Available Methods

The publishing logic adds several helpful methods to content resource objects.

| Method             | Description
| :----------------- | :----------
| `published?`       | Returns `true` if the resource is currently visible to the public
| `scheduled?`       | Returns `true` if the resource's publication date is in the future
| `draft?`           | Returns `true` if the resource's frontmatter has `draft: true` or `published: false`
| `preview?`         | Returns `true` if the resource's frontmatter has `preview: true` and is not `published?`. Aliased as `previewable?`
| `publication_date` | Returns the `Time` object for when the resource is/was published. Aliased as `published_at`
| `scheduled_at`     | Returns the publication date, but only if the resource is scheduled (otherwise returns `nil`)


## Viewing Unpublished Content

For development or preview/staging environments, globally override the publishing rules to make all content visible, including drafts and scheduled posts. This is done by setting `Perron.configuration.view_unpublished = true` (defaults to `Rails.env.development?`, so content can always be previewed in development).
