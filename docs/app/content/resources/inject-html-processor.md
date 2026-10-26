---
type: snippet
author: rails-designer
title: Inject HTML snippets
description: This snippet adds a processor to inject custom HTML (like newsletter signups, ads or CTAs) into long-form content at a natural breaking point.
category: processor
---
This snippet adds a processor to inject custom HTML snippets into long-form content at a natural breaking point in the reading flow.


## Use cases

- **Newsletter signups**: Capture emails from engaged readers
- **Advertisements**: Place ads in long articles without disrupting short posts
- **Related content**: Suggest related articles or products (use [related resources](/docs/related-resources/)


## Configuration

Customize the processor by overriding these methods:

- `MINIMUM_CHARACTER_COUNT`
- `snippet`

The processor only runs on content that exceeds the minimum length, keeping short posts clean.