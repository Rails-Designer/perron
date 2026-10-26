---
type: snippet
author: rails-designer
title: App icon setup
description: Generate all necessary icon files from a single SVG source.
category: setup
---
This script automates your site's icon setup by converting a single `icon.svg` source file into all the formats needed for favicons. It handles the entire process: validation, conversion, optimization and integration into your layout.

> [!tip]
> You can use the free [Pinturax](https://pinturax.com/editor/icons/) editor to create your icon

**Requirements:**
- [ImageMagick](https://imagemagick.org/) (`magick`)
- [Inkscape](https://inkscape.org/) (`inkscape`)
- [SVGO](https://github.com/svg/svgo) (`svgo`)
- An `icon.svg` file in your Rails root directory