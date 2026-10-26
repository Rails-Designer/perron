---
section: content
position: 4
title: Frontmatter
description: Frontmatter is supported in resources.
toc: false
---

Perron supports frontmatter. It is a way to set metadata for that content, using yaml—a key-value system.

It is added at the beginning of the markdown file and set between three dashes (`---`). Something like this:
```yaml
---
title: Frontmatter
description: Frontmatter is supported in resources.
---
```

And it is typically used for data that is not directly visible, like for [metatags](/docs/metatags/).


## Usage

All defined frontmatter on a resource is available at the `metadata` method. Given above example, `@resource.metadata.title` and `@resource.metadata.description` would output their values.


## Custom slugs

Override the default slug (derived from filename) by setting `slug` in the frontmatter:

```markdown
---
title: About Us
slug: about-us
---
```

This changes the lookup from filename to the custom slug. For example, a file named `about.md` with `slug: about-us` would be accessed via `Content::Page.find("about-us")` instead of `Content::Page.find("about")`.


## Additional metadata

Several frontmatter keys are used in various features in Perron:

- `updated_at`; last modification date (used in sitemaps and feeds)
- `sitemap_priority`; override sitemap priority for this resource
- `sitemap_change_frequency`; override change frequency for this resource
- `exclude_from_sitemap`; exclude this resource from the sitemap
- `exclude_from_feed`; exclude this resource from feeds
