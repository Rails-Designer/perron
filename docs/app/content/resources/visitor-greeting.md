---
type: component
author: rails-designer
title: Visitor greeting custom element
description: Display personalized greetings based on referrer or ref parameter.
---
This custom element displays personalized messages to visitors based on where they came from. It checks both the HTTP referrer and the `ref` URL parameter.


## Usage

Add the custom element to your page and define templates for different sources:

```html
<visitor-greeting>
  <template for="producthunt">👋 Hello Product Hunter!</template>
  <template for="news.ycombinator">🧡 Welcome Hacker News reader!</template>
  <template for="reddit">🤖 Hey Redditor!</template>
</visitor-greeting>
```

The element will:
1. Check the `ref` URL parameter first (e.g., `?ref=producthunt`)
2. Fall back to the HTTP referrer header
3. Match against the `for` attribute using substring matching
4. Display the first matching template's content


## Customization

You can use any HTML in your templates:

```html
<visitor-greeting>
  <template for="producthunt">
    <h2>Welcome Product Hunters! 😻</h2>

    <p>Special offer: 20% off with code HUNT20</p>
  </template>
</visitor-greeting>
```

Style the element with CSS to make it a banner, dialog or anything else you need.