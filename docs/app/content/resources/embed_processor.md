---
type: snippet
author: rails-designer
title: Auto-embed URLs from YouTube, Vimeo, Gists and more
description: This snippet adds a processor that transforms links to platforms, like YouTube, GitHub Gist and Loom to embeddable iframes.
category: processor
---

This processor automatically converts plain text URLs in paragraphs to embedded content. Simply paste a URL to a supported platform and it will be transformed into an interactive embed.

## Example

When you write:
\`\`\`markdown
Check out this video:

https://www.youtube.com/watch?v=dQw4w9WgXcQ
\`\`\`

It automatically becomes an embedded YouTube player instead of plain text.


## Supported platforms

- YouTube
- Vimeo
- GitHub Gist
- CodePen
- Loom


## Adding your own providers

To add support for a new platform, create a new class in `app/processors/embed_processor/` and add it to the `PROVIDERS` array in `EmbedProcessor`. Each provider needs a `matches?` method to detect URLs and an `embed` method to generate the iframe or script tag.


## Usage

Add the processor to your pipeline and paste any supported URL on its own line. The processor will detect and transform it automatically.