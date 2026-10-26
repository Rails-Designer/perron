---
type: component
author: rails-designer
title: Table of Content (using custom element)
description: A custom element for a Table of Contents component.
---
This (headless) component gives you a `<table-of-content />` custom element. It is used on this site (check out the docs). You pass it an array with items. Perron provides a `table_of_content` method on the `Perron::Resource` class that you can use for this.

You can optionally provide a `title` attribute to set a title (default to `Table of content`) or, if you want more control, a `<template type="title"></template>` to customize the content added at the top of the element. Define an `active-classes` attribute that will will be used to the ToC items when the related section is in the viewport.