---
type: snippet
author: rails-designer
title: Processor for styled blockquotes
description: This snippet adds a processor to transform GitHub-style alert syntax ([!NOTE], [!TIP], etc.) into styled blockquotes with optional icons.
category: processor
---
This snippet adds a processor to transform blockquotes into styled HTML elements, like seen on GitHub. It supports the types: *note*, *tip*, *important*, *warning* and *caution*.

The processor detects blockquotes starting with `[!type]` markers and transforms them into styled blockquotes with custom classes and optional icons using [Rails Icons](https://github.com/Rails-Designer/rails_icons/).


## Usage

```markdown
> [!note]
> This is a note with useful information.

> [!warning]
> This is a warning that requires attention.

> [!tip]
> This is a helpful tip for users.