---
title: "Adding Labels to Code Blocks"
date: 2026-08-25T15:07:36+08:00
lastmod: 2026-08-25T15:07:36+08:00
draft: true
description: "Adding Labels Code Blocks in Hugo" 
tags: [hugo, labels, papermod, codeblocks]
---

When writing technical guides, it is helpful to show which file a block of code belongs in. A plain fenced code block shows the language and syntax highlighting, but it does not display a filename or label above it.

Hugo allows attributes to be added to fenced code blocks, including a title attribute. However, the PaperMod theme does not display that title by default. To make it visible, I added a Hugo render hook and a small amount of CSS.

Create the code block render hook

From the root directory of the Hugo site, create the required folders if they do not already exist:

```bash
mkdir -p layouts/_markup
mkdir -p assets/css/extended
```
Create this file:

layouts/_markup/render-codeblock.html

Add the following code:

```html { title = "render-codeblock.html"}
{{ $result := transform.HighlightCodeBlock . }}

{{ if .Attributes.title }}
<div class="code-block">
  <div class="code-block-title">{{ .Attributes.title }}</div>
  {{ $result.Wrapped }}
</div>
{{ else }}
  {{ $result.Wrapped }}
{{ end }}
```
The render hook checks whether the code block has a title attribute. If it does, Hugo places the title above the highlighted code. Code blocks without a title continue to display normally.

This file belongs in the site's own layouts directory. It is best not to edit the copy of PaperMod inside the themes directory because those changes could be overwritten when the theme is updated.

Add the styling

PaperMod automatically loads CSS files placed in assets/css/extended. Create or edit:

assets/css/extended/custom.css

Add the following CSS:

```css {title = "custom.css"}
.code-block {
    margin: 10px 0;
}

.code-block-title {
    padding: 0.5rem 1rem;
    color: var(--secondary);
    background: var(--code-bg);
    font-size: 0.85rem;
    font-weight: 600;
    border-bottom: 1px solid var(--border);
    border-radius: var(--radius) var(--radius) 0 0;
}

.code-block .highlight {
    margin: 0;
}

.code-block .highlight pre {
    border-radius: 0 0 var(--radius) var(--radius);
}
```

The PaperMod colour variables keep the labels consistent in both light and dark modes.

Add a label to a code block

To display a filename, add {title="filename"} after the language on the opening fence:

```
 {title="hugo.yml"}
```

The result is a YAML code block with hugo.yml shown as its label.

The title can be anything useful, such as a filename, terminal, configuration section or example name:

```bash {title="Terminal"}
hugo server -D
```

Test the change

Start or restart the Hugo development server:

hugo server -D

Open the page containing the titled code block. The label should now appear directly above the code and should also change colours correctly when PaperMod switches between light and dark mode.

This provides a simple way to make technical guides clearer without modifying the PaperMod theme itself.
