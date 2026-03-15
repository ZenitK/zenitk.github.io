# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal blog and portfolio site for Zenit Kovačević, built with Jekyll using the Royce theme. Deployed to https://www.zenitk.com via Netlify (also GitHub Pages compatible).

## Common Commands

```bash
# Install dependencies
bundle install

# Run local dev server (available at http://localhost:4000)
bundle exec jekyll serve

# Build for production (output to _site/)
bundle exec jekyll build
```

## Architecture

**Jekyll static site** — content is written in Markdown/HTML, processed through Liquid templating, and output as a static site.

- `_config.yml` — site-wide settings: metadata, navigation, plugins, social links, Disqus/Analytics IDs
- `_layouts/` — page templates (`default.html` → `page.html`/`post.html`/`tag.html`)
- `_includes/` — reusable template fragments (header, footer, pagination, search, etc.)
- `_sass/` — SCSS source files compiled to `assets/css/`
- `_posts/` — blog posts organized by year, named `YYYY-MM-DD-title.md`
- `tags/` — one `.md` file per tag, references the `tag` layout

**Content pages:** `index.html`, `about.md`, `cv.md`, `contact.html`, `search.html`

**Search:** Client-side search powered by `search.json` (Jekyll-generated index) and `assets/js/search.js`.

## Adding Content

**New blog post:** Create `_posts/YYYY/YYYY-MM-DD-title.md` with front matter:
```yaml
---
layout: post
title: "Post Title"
description: "Short description"
tags: [tag1, tag2]
image: /assets/images/posts/image.jpg
---
```

**New tag:** Create `tags/tagname.md`:
```yaml
---
layout: tag
tag: tagname
---
```
