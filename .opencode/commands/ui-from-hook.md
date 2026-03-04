---
name: ui-from-hook
description: Build a game-style in-game window UI based on a user-provided hook.
arguments:
  - name: componentName
    description: Name of the UI component / window (folder name).
    required: true

  - name: uiPurpose
    description: Describe what this UI represents in the game and how the player should use it.
    required: true

  - name: layout
    description: Describe layout, sections, lists, charts, tabs, filters and interactions.
    required: true

  - name: hookPath
    description: Path to the hook file. The command will read the hook code from this file.
    required: true

  - name: placement
    description: Target directory for the new component.
    required: false
    default: components/NewComponents/{{componentName}}/

  - name: allowMockUiData
    description:
      Allow adding UI-only mock / presentation data (labels, values, badges, placeholders, grouping, colors, etc.).
    required: false
    default: true
---

Build a UI component based on the hook provided below.

**UI purpose:**  
{{uiPurpose}}

**Window type:**  
This UI must be rendered as an in-game window (Crusader Kings / Europa Universalis style).

**Behavior & layout expectations:**  
{{layout}}

**Data source:**  
Use ONLY the hook below as the primary data source. You may add UI-only mock / presentation data if needed:
{{allowMockUiData}}

**Hook:**  
Loaded from file at path `{{hookPath}}`. Focus on the data returned; TypeScript types may be in a different folder.

**Styling:**  
Follow styles from `components/**/styles/**` and project styling rules. Prefer components from `components/ui/**`.

**Placement:**

- Component file: `{{placement}}/`
- CSS Module: `{{placement}}/styles/`
