# OpenCode Prompt — Generate UI CSS Module

## Your Role

Senior UI Engineer specializing in **CSS Modules** for medieval strategy game interfaces UI.

---

# Task

Generate a **CSS module** for this component @components/NewComponents/$1.tsx UI component. Read
@components/NewComponents/$1.tsx cearfully and create **CSS module** @components/NewComponents/styles/$1.module.css

---

# Inputs

| Param | Description       |
| ----- | ----------------- |
| $1    | Component name    |
| $2    | UI purpose        |
| $3    | Layout & behavior |

---

# File To Generate

@components/NewComponents/styles/$1.module.css

---

# STRICT OUTPUT RULES

Allowed output:

- Raw CSS only

Forbidden output:

- Markdown
- Code fences
- Explanations
- Multiple files
- Shell commands

If any forbidden output appears → **regenerate**.

---

# Visual Style

Medieval parchment interface inspired by **CK3 / EU4**.

---

# Colors

Window background

#2b1810

Secondary background

#5a4022

Content panels

#e6c998 #f0d9a0

Borders

1px–2px solid #c89a4a

Accent color

#d4a574

---

# Typography

Titles

font-family: 'Cinzel', serif

Body

system serif

---

# CSS Structure

`.window`

- main container
- dark background
- gold border
- box-shadow depth

---

`.titleBar`

- darker header strip
- bottom border

---

`.title`

- Cinzel font
- gold color

---

`.content`

- parchment background
- padding

---

`.row`

- flex horizontal layout
- spaced elements

---

`.stat`

- icon + value layout

---

`.badge`

- gold framed stat block

---

`.pips`

- small circular dots
- used for levels

---

# Hover Behavior

Interactive rows highlight with:

background: rgba(212,165,116,0.15)

---

# Texture

Use subtle parchment gradients where appropriate.

---

# Final Validation

Before returning output verify:

- output contains only CSS
- only one file generated
- no explanations
- no markdown

If any rule is violated → **regenerate**.
