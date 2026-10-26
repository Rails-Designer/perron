---
section: meta
position: 10
title: Related resources
description: Perron's related resources features returns similar resources as the current one using the TF-IDF algorithm.
toc: false
---

The `related_resources` method allows to find and display a list of similar resources from the same collection. Similarity is calculated using the **[TF-IDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf)** algorithm on the content of each resource.


## Usage

To get a list of the 5 most similar resources, call the method on any resource instance.
```ruby
# app/views/content/posts/show.html.erb
@resource.related_resources

# Just the 3 most similar resources
@resource.related_resources(limit: 3)
```
