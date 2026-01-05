---
title: Inline ERB post
author: Rails Designer
editor_id: author-1
---

This is a regular paragraph in the post. It should not be processed by ERB.

Here is a special block that should be erbified:
<%= erbify do %>
  The slug for this resource is: <%= @resource.slug %> and is it authored by <%= @resource.metadata.author %>
<% end %>

And one more paragraph for good measure.
