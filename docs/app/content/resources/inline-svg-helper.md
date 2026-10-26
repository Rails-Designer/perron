---
type: snippet
author: rails-designer
title: Inline SVG helper
description: A Ruby on Rails helper to inline your SVG files for Perron.
category: styling
---
A Rails helper to inline SVG files ([that are not icons](https://github.com/rails-designer/rails_icons)). It expects SVG files in `app/assets/svg/`. Syntax is `svg "blob"`. You can optionally pass options, like `class` or hash-like options, like `aria: {hidden: true}`.