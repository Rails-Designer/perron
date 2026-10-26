---
section: meta
position: 11
title: XML sitemap
description: For bigger sites, a XML sitemap can help to get quicker indexed.
---


A sitemap is a XML file that lists all the pages of a website to help search engines discover and index content more efficiently, containing URLs, last modification dates, change frequency and priority values.

Enable it with the following line in the Perron configuration:
```ruby
Perron.configure do |config|
  # …
  config.sitemap.enabled = true
  # config.sitemap.priority = 0.8
  # config.sitemap.change_frequency = :monthly
  # …
end
```

Values can be overridden per collection…
```ruby
# app/models/content/post.rb
class Content::Post < Perron::Resource
  configure do |config|
    config.sitemap.enabled = false
    config.sitemap.priority = 0.5
    config.sitemap.change_frequency = :weekly
  end
end
```

…or on a resource basis:
```ruby
---
sitemap: false
sitemap_priority: 0.25
sitemap_change_frequency: :daily
---
```


## Last modification date

The sitemap includes a `<lastmod>` element based on the resource's `updated_at` frontmatter value:
```markdown
---
title: My Post
updated_at: 2025-04-20
---
```

If `updated_at` is not set, the file's modification time is used as a fallback.


## Explanation of priority

- **1.0 – 0.8: high priority**; homepage, product information, landing pages, category pages
- **0.7 – 0.4: mid-range priority**; news articles, weather services, blog posts, pages that no site would be complete without
- **0.3 – 0.0: low priority**; FAQs, old news stories, old press releases, completely static pages that are still relevant


## Do you need a XML sitemap?

If your site is "small", you do not need one. Small, meaning ~500 pages (that needs to be in search results) or less on your site.
