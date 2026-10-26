---
type: snippet
author: rails-designer
title: Surge
description: Add a complete deployment script for surge.sh static site hosting with perron.
about: "Surge is a simple, single-command static web publishing platform for front-end developers. Deploy sites instantly from the command line with custom domains, free ssl and no configuration required."
category: deployment
position: 3
---
This snippet adds a deployment binstub for your Perron-powered static site to [Surge.sh](https://surge.sh). It creates a CNAME file for your domain, install the surge package and a complete deploy binstub that handles the entire workflow: building your site, deploying to Surge.sh and cleaning up the output directory afterward.