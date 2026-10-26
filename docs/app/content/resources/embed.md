---
type: component
author: rails-designer
title: Embed Content
description: A web component for embedding dynamic JSON content with toggle, caching and read state tracking.
---
Headless component for embedding content from JSON endpoints.


## Usage

```erb
<embed-content src="http://localhost:3001/posts.json">
  <button toggle>Toggle</button>

  <ul items hidden></ul>
</embed-content>
```


## Attributes

| Attribute | Description | Default |
|-----------|-------------|---------|
| `src` | URL to JSON endpoint | - |
| `cache-max-age` | Cache duration in seconds | 86400 (24 hours) |
| `limit` | Maximum number of items to display | - (no limit) |
| `last-read-at` | ISO timestamp to track read state | - |


## Slots

| Selector | Description |
|----------|-------------|
| `[toggle]` | Clickable element to show/hide |
| `[items]` | Container for rendered items |
| `[badge]` | Element synced with `total-unread` count |


## State Attributes

| Attribute | When Set |
|-----------|----------|
| `[loading]` | Fetching content |
| `[error]` | Fetch failed |
| `[total-unread]` | Count of unread items |


## Caching

Content is cached in localStorage to reduce network requests. Set `cache-max-age` to control freshness:
```erb
<embed-content src="/posts.json">
<embed-content src="/posts.json" cache-max-age="3600">
<embed-content src="/posts.json" cache-max-age="0">
```


## Limiting Items

```erb
<embed-content src="/posts.json" limit="5">
  <ul items></ul>
</embed-content>
```


## Read State Tracking

```erb
<changelog-embed src="/posts.json" last-read-at="2026-03-28T09:00:00Z">
  <button toggle>Changelog <span badge></span></button>

  <ul items hidden></ul>
</changelog-embed>
```

The `total-unread` attribute is automatically synced to any `[badge]` element inside the component.


## Extending

```js
import { EmbedContent } from "components/embed-content"

class BlogEmbed extends EmbedContent {
  get template() {
    return (item) => `<article>${item.title}</article>`
  }
}
customElements.define("blog-embed", BlogEmbed)
```


## JSON Response

The `src` endpoint should return an array of items:
```json
[
  {
    "id": 1,
    "title": "Hello World",
    "body": "Post content...",
    "url": "/posts/hello-world",
    "published_at": "2026-03-28T09:00:00Z"
  }
]
```