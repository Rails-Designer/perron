---
type: component
author: rails-designer
title: Countdown (using custom element)
description: A custom element for countdown timers.
---
This (headless) component gives you a `<count-down />` custom element. It displays a countdown timer to a specific date and time, updating every second.


## Usage

Provide a `to-time` attribute with an ISO 8601 datetime string:
```html
<count-down to-time="2026-12-31T23:59:59Z"></count-down>
```

This will display the countdown in the format: `*d *h *m *s`


### Timezones

Include timezone information directly in the `to-time` value:
```html
<!-- UTC time -->
<count-down to-time="2026-12-31T23:59:59Z"></count-down>

<!-- Specific timezone offset -->
<count-down to-time="2026-12-31T23:59:59-05:00"></count-down>

<!-- Another timezone -->
<count-down to-time="2026-12-31T23:59:59+01:00"></count-down>
```

### Custom completion text

Use the `complete-text` attribute to customize what displays when the countdown reaches zero:
```html
<count-down to-time="2026-12-31T23:59:59Z" complete-text="Sale ended!"></count-down>
```

Default completion text is `0d 0h 0m 0s`.


### Styling on completion

When the countdown reaches zero, a `complete` attribute is added to the element. Use this to style the completed state:
```css
count-down[complete] {
  color: red;
  font-weight: bold;
}
```