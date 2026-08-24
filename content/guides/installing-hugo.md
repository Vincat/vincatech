---
title: "Installing Hugo"
date: 2026-08-24T09:36:02+08:00
lastmod: 2026-08-24T09:36:02+08:00
draft: true
description: "Hugo setup guide"
tags: [hugo, blog, guides]
---

Below is how I got my Techblog started.

```bash
sudo dnf install hugo
hugo version
dnf info hugo
hugo new site techblog
cd ./techblog
git init
git submodule add https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
rm hugo.toml
nvim hugo.yml
```

## Content types
3 types of content , Blog(posts), Guides, and Projects.

```bash
hugo new content posts/my-first-post.md --> content/posts/my-first-post.md

hugo new content guides/proton-drive.md --> content/guides/proton-drive.md

hugo new content projects/pico-dice.md --> content/projects/pico-dice.md
```

