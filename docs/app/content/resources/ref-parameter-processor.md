---
type: snippet
author: rails-designer
title: Processor to add `?ref` parameter to links
description: This snippet adds a processor for the `markdownify` helper to add a `?ref` parameter to your outgoing links.
category: processor
---
This snippet adds a processor for the `markdownify` helper to add a `?ref` parameter to your outgoing links, it skips internal links—those starting with a `/` and `#` (anchors).

You can set the ref value in the created processor by setting the `REF_VALUE` constant.