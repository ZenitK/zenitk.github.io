# Zenit Kovačević Blog

Personal Jekyll blog for [zenitk.com](https://www.zenitk.com), focused on information retrieval, data analysis, music, and software engineering.

## Stack

- Jekyll
- GitHub Pages gem bundle
- Sass partials in `_sass/`
- Jekyll plugins:
  - `jekyll-paginate`
  - `jekyll-seo-tag`
  - `jekyll-sitemap`
  - `jekyll-target-blank`
  - `jemoji`

## Local Development

Install dependencies:

```bash
bundle install
```

Run the site locally:

```bash
bundle exec jekyll serve
```

Build the static site:

```bash
bundle exec jekyll build
```

The generated site is written to `_site/`.

## Content Structure

- `_posts/` contains blog posts
- `about.md`, `cv.md`, `contact.html` contain top-level pages
- `_layouts/` contains Jekyll page and post layouts
- `_includes/` contains shared partials
- `_sass/` and `assets/css/style.scss` define the visual system
- `assets/images/` contains author, page, and post imagery

## Configuration

Main site configuration lives in [`_config.yml`](/Users/zenit/Blog/zenitk.github.io/_config.yml).

Important fields:

- `name`: site title
- `description`: sidebar descriptor
- `author.image`: avatar shown in the sidebar
- `author.greetings`: homepage hero headline and intro
- `navigation`: main nav items
- `url`: production domain used for canonical and social metadata
- `baseurl`: subpath support if the site is ever hosted below a root domain
- `formspree`: contact form endpoint

## Authoring Notes

Create a new post in `_posts/YYYY/YYYY-MM-DD-title.md` with front matter similar to:

```yaml
---
layout: post
title: My Post Title
featured_image: /assets/images/posts/2026/example/example.jpg
tags:
  - tag-one
  - tag-two
---
```

Featured posts can be highlighted on the homepage with:

```yaml
featured: true
```

## Images

Page and post images live in `assets/images/`.

For captioned images inside markdown content:

```liquid
{% include image-caption.html imageurl="/assets/images/example.jpg" title="Title" caption="Caption" %}
```

For wide images inside posts:

```liquid
{% include image-caption.html imageurl="/assets/images/example.jpg#wide" title="Title" caption="Caption" %}
```

Note: wide/full image breakout styling is intended for posts. Static pages such as About are constrained back to a normal content width.

## Linking

Internal navigation should generally use relative links via `{{ site.baseurl }}`.

Absolute URLs are still used for SEO metadata in the default layout. This avoids local development links unexpectedly redirecting to production while keeping canonical and Open Graph tags correct.

## Deployment

This repository includes `netlify.toml`, but it can also be deployed anywhere Jekyll static output is supported.

Typical deployment flow:

1. Run `bundle exec jekyll build`
2. Deploy the generated `_site/` output or connect the repository to your hosting provider

## Maintenance

Before committing changes, run:

```bash
bundle exec jekyll build
```

That catches Liquid, config, and Sass regressions quickly.
