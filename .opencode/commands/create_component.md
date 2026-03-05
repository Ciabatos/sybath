Build a UI component for the Sybath game. Focus on rendering things not functions for interactions ! ONLY CREATE TWO
FILES

## Step 1

- `components/` you will find all similar components and module.css for css class use that as the reference when
  examples in this promt will not be sufficient.
- Here are some examples of existing component :

```tsx
"use client"

import { Button } from "@/components/ui/button"
import { AlertCircle, ArrowRight, Clock, Flame, Hand, Loader, Sparkles, Sunrise, Tent, UserCheck } from "lucide-react"
import { useState } from "react"
import styles from "./styles/PlayerCamp.module.css"

export default function PlayerCamp() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [isSetupComplete, setIsSetupComplete] = useState<boolean>(false)
  const [isReadyToRest, setIsReadyToRest] = useState<boolean>(false)
  const [isCampfireActive, setIsCampfireActive] = useState<boolean>(false)
  const [isEncumbered, setIsEncumbered] = useState<boolean>(false)
  const [timeRemaining, setTimeRemaining] = useState<number>(60)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    mapTileName: "The Weeping Woods", // mock
    mapTileCoordinates: "[1247, 892]", // mock
    mapTileTerrain: "Forest", // mock
    mapTileRegion: "Northern Marches", // mock

    playerHunger: 4, // mock
    playerFatigue: 3, // mock
    playerTemperature: 2, // mock
    currentEncumbrance: 12, // mock
    maxEncumbrance: 50, // mock
    encumbranceLevel: "Light", // mock

    campingSince: "2d 4h", // mock
    dayNightCycle: "Evening", // mock
    timeUntilDawn: "6h 23m", // mock
    timeElapsed: "2 days, 4 hours", // mock

    gainedConditions: [
      // mock
      { id: "1", name: "Rested", icon: "☀️", description: "+2 Morale, -1 Fatigue" },
      { id: "2", name: "Hungry", icon: "😴", description: "Stomach growls occasionally" },
    ],

    campfireEffects: [
      // mock
      { id: "1", name: "Light & Warmth", value: "+10°C" },
      { id: "2", name: "Morale Boost", value: "+5%" },
      { id: "3", name: "Safe Haven", value: "-3x Ambush chance" },
    ],

    availableActions: ["Move Out", "Wake Up", "Prepare Meal", "Tend Fires"], // mock

    pendingActions: [
      // mock
      { id: "1", name: "Watch Fires", status: "Ready" },
      { id: "2", name: "Practice Arms", status: "Ready" },
      { id: "3", name: "Study Maps", status: "Ready" },
    ],

    gatheredResources: [
      // mock
      { id: "1", name: "Dripping Moss", quantity: "1x", icon: "🌿" },
      { id: "2", name: "Forest Bream", quantity: "2x", icon: "🐟" },
      { id: "3", name: "Hard Wood", quantity: "1x", icon: "🪵" },
    ],
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const encumbrancePercentage =
    MOCK.maxEncumbrance === 0 ? 0 : Math.round((MOCK.currentEncumbrance / MOCK.maxEncumbrance) * 100)

  const isHunted = MOCK.playerTemperature >= 2
  const isHungerCritical = MOCK.playerHunger >= 3

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleWakeUp() {
    setIsSetupComplete(false)
    setIsReadyToRest(false)
  }

  function handleMoveOut() {
    console.log("Moving out from camp")
  }

  function handleSetupCamp() {
    setIsSetupComplete(true)
  }

  function handleAdjustFire() {
    setIsCampfireActive(function (prev) {
      return !prev
    })
  }

  function handleClose() {
    console.log("Closing camp interface")
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>{MOCK.mapTileName}</h2>
          <p className={styles.subTitle}>
            {MOCK.mapTileTerrain} · {MOCK.mapTileRegion}
          </p>
          <span className={styles.coordinates}>{MOCK.mapTileCoordinates}</span>
        </div>
        <Button
          onClick={handleClose}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <AlertCircle className={styles.closeIcon} />
        </Button>
      </div>

      {/* CONTENT */}
      <div className={styles.content}>
        {/* Camp status */}
        <section className={styles.section}>
          <div className={styles.restingStatus}>
            <Tent className={styles.readyIcon} />
            <div className={styles.restingInfo}>
              <span className={styles.restingName}>Camping</span>
              {isReadyToRest && <span className={styles.restingEffect}>Ready to rest</span>}
            </div>
          </div>
        </section>

        {/* Conditions */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Conditions</h3>
          <div className={styles.conditionsContainer}>
            {isHunted && (
              <div className={styles.condition}>
                <Sunrise className={styles.conditionIcon} />
                <span className={styles.conditionName}>Hunted</span>
                <span className={styles.conditionValue}>Active</span>
              </div>
            )}
            {isHungerCritical && (
              <div className={styles.condition}>
                <AlertCircle className={styles.conditionIcon} />
                <span className={styles.conditionName}>Hungry</span>
                <span className={styles.conditionValue}>{MOCK.playerHunger}/5</span>
              </div>
            )}
            {MOCK.playerFatigue > 1 && (
              <div className={styles.condition}>
                <Loader className={styles.conditionIcon} />
                <span className={styles.conditionName}>Fatigued</span>
                <span className={styles.conditionValue}>{MOCK.playerFatigue}/5</span>
              </div>
            )}
            {isEncumbered && (
              <div className={styles.condition}>
                <UserCheck className={styles.conditionIcon} />
                <span className={styles.conditionName}>Burdened</span>
                <span className={styles.conditionValue}>
                  {MOCK.currentEncumbrance}/{MOCK.maxEncumbrance}
                </span>
              </div>
            )}
          </div>
        </section>

        {/* Encumbrance */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Encumbrance</h3>
          <div className={styles.encumbranceContainer}>
            <Hand className={styles.encumbranceIcon} />
            <div className={styles.encumbranceInfo}>
              <span className={styles.encumbranceLabel}>
                {MOCK.currentEncumbrance} / {MOCK.maxEncumbrance}
              </span>
              <span className={styles.encumbranceStatus}>{MOCK.encumbranceLevel}</span>
            </div>
            <span className={styles.encumbrancePercentage}>{encumbrancePercentage}%</span>
          </div>
        </section>

        {/* Campfire */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Campfire</h3>
          <div className={styles.campfireContainer}>
            <Flame className={styles.flameIcon} />
            <span className={styles.campfireName}>Campfire ({isCampfireActive ? "Active" : "Unlit"})</span>
          </div>
          <div className={styles.conditionsContainer}>
            {MOCK.campfireEffects.map(function (effect) {
              return (
                <div
                  key={effect.id}
                  className={styles.condition}
                >
                  <AlertCircle className={styles.conditionIcon} />
                  <span className={styles.conditionName}>{effect.name}</span>
                  <span className={styles.conditionValue}>{effect.value}</span>
                </div>
              )
            })}
          </div>
        </section>

        {/* Time & Cycle */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Time & Cycle</h3>
          <div className={styles.timeRemainingContainer}>
            <Clock className={styles.timeRemainingIcon} />
            <span className={styles.timeRemainingValue}>{timeRemaining} min</span>
            <span className={styles.timeRemainingLabel}>until dawn</span>
          </div>
          <span className={styles.campingSince}>Camping since: {MOCK.campingSince}</span>
        </section>

        {/* Effects */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Effects</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.gainedConditions.map(function (condition) {
              return (
                <div
                  key={condition.id}
                  className={styles.condition}
                >
                  <span className={styles.conditionEmoji}>{condition.icon}</span>
                  <span className={styles.conditionName}>{condition.name}</span>
                  <span className={styles.conditionValue}>{condition.description}</span>
                </div>
              )
            })}
          </div>
        </section>

        {/* Actions */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Actions</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.availableActions.map(function (action, index) {
              return (
                <div
                  key={index}
                  className={styles.condition}
                >
                  <ArrowRight className={styles.conditionIcon} />
                  <span className={styles.conditionName}>{action}</span>
                </div>
              )
            })}
          </div>
        </section>

        {/* Pending Activity */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Pending Activity</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.pendingActions.map(function (action) {
              return (
                <div
                  key={action.id}
                  className={styles.condition}
                >
                  <Sparkles className={styles.conditionIcon} />
                  <span className={styles.conditionName}>{action.name}</span>
                  <span className={styles.conditionValue}>{action.status}</span>
                </div>
              )
            })}
          </div>
        </section>

        {/* Resources Gathered */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Resources Gathered</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.gatheredResources.map(function (resource) {
              return (
                <div
                  key={resource.id}
                  className={styles.condition}
                >
                  <span className={styles.conditionEmoji}>{resource.icon}</span>
                  <span className={styles.conditionName}>{resource.name}</span>
                  <span className={styles.conditionValue}>{resource.quantity}</span>
                </div>
              )
            })}
          </div>
        </section>

        {/* Action buttons */}
        <div className={styles.actionButtons}>
          <Button
            className={styles.campActionButton}
            onClick={handleWakeUp}
            disabled={!isSetupComplete}
          >
            Wake Up
          </Button>
          <Button
            className={styles.campActionButton}
            onClick={handleMoveOut}
            disabled={!isSetupComplete}
          >
            Move Out
          </Button>
          <Button
            className={styles.campActionButton}
            variant='outline'
            onClick={handleSetupCamp}
            disabled={isSetupComplete}
          >
            Setup Camp
          </Button>
          <Button
            className={styles.campActionButton}
            variant='outline'
            onClick={handleAdjustFire}
            disabled={!isSetupComplete}
          >
            Adjust Fire
          </Button>
        </div>

        {/* Hints */}
        {isSetupComplete && <p className={styles.hintText}>Stay alert! The fire will extinguish when you move out.</p>}

        {!isSetupComplete && (
          <div className={styles.emptyState}>
            <Tent className={styles.emptyStateIcon} />
            <p>Press &quot;Setup Camp&quot; to set up camp on this map tile.</p>
          </div>
        )}
      </div>
    </div>
  )
}
```

and styles just like here

```css
.panel {
  display: flex;
  flex-direction: column;
  box-shadow:
    -4px 0 20px rgba(0, 0, 0, 0.7),
    inset 0 0 30px rgba(0, 0, 0, 0.3),
    inset 0 0 80px rgba(0, 0, 0, 0.5);
  border-left: 3px solid #5a4022;
  background: linear-gradient(135deg, #1a0f08 0%, #2b1810 50%, #1a0f08 100%);
  width: 100%;
  min-width: 420px;
  overflow: hidden;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
  border-bottom: 2px solid #c89a4a;
  background: linear-gradient(to bottom, #2b1810, #1a0f08);
  padding: 20px;
}

.titleSection {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: 4px;
}

.title {
  margin: 0;
  color: #d4a574;
  font-weight: 700;
  font-size: 22px;
  font-family: "Cinzel", serif;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8);
}

.subTitle {
  opacity: 0.85;
  margin: 0;
  color: #e6c998;
  font-style: italic;
  font-size: 12px;
  font-family: "Lora", serif;
}

.coordinates {
  opacity: 0.8;
  color: #c89a4a;
  font-size: 12px;
  font-family: "Lora", serif;
}

.closeButton {
  transition: all 0.2s ease;
  border: 1px solid #4a3728;
  border-radius: 4px;
  background: rgba(74, 55, 40, 0.5);
  padding: 0;
  width: 36px;
  height: 36px;
  color: #c89a4a;
}

.closeButton:hover {
  transform: scale(1.05);
  border-color: #c89a4a;
  background: rgba(74, 55, 40, 0.8);
}

.closeIcon {
  width: 18px;
  height: 18px;
}

.content {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: 20px;
  box-shadow: inset 0 2px 10px rgba(0, 0, 0, 0.2);
  background: #e6c998;
  padding: 20px;
  overflow-y: auto;
}

.section {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.sectionTitle {
  margin: 0;
  border-bottom: 1px solid #c89a4a;
  padding-bottom: 8px;
  color: #2b1810;
  font-weight: 600;
  font-size: 15px;
  font-family: "Cinzel", serif;
  letter-spacing: 1px;
  text-transform: uppercase;
}

/* Resting & Survival */
.restingContainer {
  display: flex;
  align-items: center;
  gap: 16px;
  border: 1px solid #5a4022;
  border-radius: 4px;
  background: rgba(43, 24, 16, 0.4);
  padding: 16px;
}

.restingStatus {
  display: flex;
  align-items: center;
  gap: 12px;
}

.restingIndicator {
  display: flex;
  align-items: center;
  gap: 8px;
  border: 2px solid #c89a4a;
  border-radius: 4px;
  background: linear-gradient(135deg, #5a4022, #3d2a1c);
  padding: 8px 14px;
  min-width: 140px;
}

.readyIcon {
  width: 16px;
  height: 16px;
  color: #d4a574;
}

.restingInfo {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.restingName {
  color: #2b1810;
  font-weight: 600;
  font-size: 13px;
  font-family: "Cinzel", serif;
}

.restingEffect {
  opacity: 0.8;
  color: #5a4022;
  font-size: 11px;
  font-family: "Lora", serif;
}

.restingProgress {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 120px;
}

.restingSpinner {
  width: 24px;
  height: 24px;
}

.restingTime {
  color: #5a4022;
  font-weight: 600;
  font-size: 12px;
  font-family: "Cinzel", serif;
}

.restingHint {
  display: block;
  opacity: 0.8;
  color: #c89a4a;
  font-size: 10px;
  font-family: "Lora", serif;
}

/* Conditions */
.conditionsContainer {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 8px;
}

.condition {
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.2s ease;
  border: 1px solid #5a4022;
  border-radius: 4px;
  background: rgba(61, 36, 21, 0.3);
  padding: 8px 12px;
}

.condition:hover {
  border-color: #c89a4a;
  background: rgba(61, 36, 21, 0.5);
}

.conditionIcon {
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
  color: #d4a574;
  font-size: 16px;
}

.conditionName {
  color: #2b1810;
  font-weight: 500;
  font-size: 12px;
  font-family: "Lora", serif;
}

.conditionValue {
  margin-left: auto;
  color: #c89a4a;
  font-weight: 600;
  font-size: 12px;
  font-family: "Cinzel", serif;
}

.conditionTooltip {
  display: flex;
  align-items: center;
  gap: 6px;
}

/* Campfire */
.campfireContainer {
  display: flex;
  position: relative;
  justify-content: center;
  align-items: center;
  gap: 20px;
  border: 2px solid #c89a4a;
  border-radius: 8px;
  background: rgba(74, 55, 40, 0.6);
  padding: 16px;
  overflow: hidden;
}

.campfireName {
  color: #d4a574;
  font-weight: 600;
  font-size: 14px;
  font-family: "Cinzel", serif;
  text-align: center;
  text-shadow: 0 0 10px rgba(200, 154, 74, 0.5);
}

/* Hunger Bar */
.hungerContainer {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}

.hungerCell {
  flex: 1;
  border: 1px solid #5a4022;
  border-radius: 3px;
  background: rgba(74, 55, 40, 0.6);
  height: 8px;
  overflow: hidden;
}

.hungerCell.hungry {
  border-color: #dc2626;
  background: #f87171;
}

.hungerCell.satiated {
  border-color: #22c55e;
  background: #4ade80;
}

.hungerCell.fatigued {
  border-color: #3b82f6;
  background: #60a5fa;
}

/* Encumbrance */
.encumbranceContainer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  border: 1px solid #5a4022;
  border-radius: 4px;
  background: rgba(61, 36, 21, 0.3);
  padding: 10px 12px;
}

.encumbranceIcon {
  flex-shrink: 0;
  width: 20px;
  height: 20px;
  color: #d4a574;
}

.encumbranceInfo {
  display: flex;
  flex: 1;
  flex-direction: column;
}

.encumbranceLabel {
  color: #c89a4a;
  font-size: 11px;
  font-family: "Lora", serif;
}

.encumbranceValue {
  color: #e6c998;
  font-weight: 600;
  font-size: 13px;
  font-family: "Cinzel", serif;
}

.encumbranceStatus {
  color: #d4a574;
  font-style: italic;
  font-size: 11px;
  font-family: "Lora", serif;
}

/* Day/Night Cycle */
.dayNightContainer {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}

.dayNightCell {
  flex: 1;
  border: 1px solid #5a4022;
  border-radius: 3px;
  background: rgba(74, 55, 40, 0.6);
  height: 8px;
  overflow: hidden;
}

.dayNightCell.day {
  border-color: #c89a4a;
  background: #e6c998;
}

.dayNightCell.night {
  border-color: #3d3a36;
  background: #2d2a26;
}

/* Time Remaining */
.timeRemainingContainer {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 8px;
  border: 1px solid #5a4022;
  border-radius: 4px;
  background: rgba(43, 24, 16, 0.4);
  padding: 12px;
}

.timeRemainingIcon {
  flex-shrink: 0;
  width: 20px;
  height: 20px;
  color: #d4a574;
}

.timeRemainingValue {
  color: #e6c998;
  font-weight: 600;
  font-size: 13px;
  font-family: "Cinzel", serif;
}

.timeRemainingLabel {
  color: #c89a4a;
  font-size: 11px;
  font-family: "Lora", serif;
}

/* Buttons */
.actionButtons {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 8px;
}

.campActionButton {
  transition: all 0.2s ease;
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.1),
    0 2px 4px rgba(0, 0, 0, 0.5);
  border: 2px solid #c89a4a;
  border-radius: 4px;
  background: linear-gradient(to bottom, #5a4738, #4d3525);
  min-height: 42px;
  color: #c89a4a;
  font-weight: 600;
  font-size: 14px;
  font-family: "Cinzel", serif;
  letter-spacing: 0.5px;
}

.campActionButton:hover {
  transform: translateY(-2px);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.1),
    0 4px 8px rgba(0, 0, 0, 0.6),
    0 0 12px rgba(200, 154, 74, 0.3);
  border-color: #d4a574;
  background: linear-gradient(to bottom, #6b5440, #564330);
}

.campActionButton:active {
  transform: translateY(0);
  box-shadow:
    inset 0 2px 4px rgba(0, 0, 0, 0.4),
    0 1px 2px rgba(0, 0, 0, 0.5);
}

.campActionButton:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Warning/Hint */
.hintText {
  margin-top: 8px;
  border: 1px solid #5a4022;
  border-radius: 4px;
  background: rgba(74, 55, 40, 0.3);
  padding: 8px 10px;
  color: #c89a4a;
  font-size: 11px;
  line-height: 1.5;
  font-family: "Lora", serif;
  text-align: center;
}

/* Empty state */
.emptyState {
  padding: 40px 20px;
  color: #c89a4a;
  font-style: italic;
  font-family: "Lora", serif;
  text-align: center;
}

.emptyStateIcon {
  display: block;
  opacity: 0.6;
  margin-bottom: 12px;
  font-size: 48px;
}
```

## Step 2 — Think before coding

Before writing any file, briefly plan:

- What sections does this window need? (header, list, sidebar, footer, etc.)
- What data you need to mock?
- What CSS classes will be needed?

## Inputs

- **Component name**: $1
- **UI purpose**: $2
- **Layout & behavior**: $3
- **Hook file path**: $4
- **Mock data allowed**: $5

## Only files to create or edit !

- `components/NewComponents/$1.tsx`
- `components/NewComponents/styles/$1.module.css`

- Do NOT run shell commands to create directories. Just write the files directly — the editor creates directories
- Automatically. Skip any `mkdir` or `cd` steps. Folders NewComponents and styles exists
- Do not look for hooks

---

## Project context

Medieval/fantasy strategic/rpg turn-based game on world map grid with coordinates x and y. Next.js 16 App Router ·
TypeScript · CSS Modules · Jotai · SWR · lucide-react · Radix UI.

**Colors:** `#2b1810` dark brown · `#5a4022` brown · `#d4a574`/`#c89a4a` gold · `#e6c998` cream  
**Fonts:** `Cinzel` for titles · system serif for body  
**Aesthetic:** CK3/EU4 panel — parchment, metallic accents, framed container

**Hard rules:**

- Use type instead of interface
- `"use client"` at top
- `useState` — top of component body, UI state only (tabs, toggles, open/close)
- Hook call — inside component body only
- Internal functions — traditional `function` syntax only
- Semantic class names only (`.panel`, `.row`, `.badge`) no Tailwind
- Use `components/ui/**` for Button, Dialog, Tooltip, etc.
- Focus on **rendering only** stub all handlers, do not implement business logic.
- Represent numeric stats as icon + value pairs, never plain text labels alone
- Use colored dot/pip elements for levels (1–5 stars, health bars, morale pips)
- Never conditionally hide actions — show grayed

If $5 is yes:

- Define ONE flat MOCK object. No deep nesting — max 2 levels inside component body
- Define MOCK **inside the component function body**, after useState declarations.
- MOCK data — read directly in JSX with `MOCK.value`, never via `setState(MOCK.something)`
- Never copy MOCK values into state — if it comes from the hook/MOCK, render it directly

---

## CSS Module rules (`$1.module.css`)

- Background: `#2b1810` for window, `#e6c998` / `#f0d9a0` for content areas
- Borders: `1px–2px solid #c89a4a` with `box-shadow` for depth
- Title: `font-family: 'Cinzel', serif` · color `#d4a574`
- Hover states: gold highlight `#d4a574` on interactive rows
- Parchment feel: slight `background-image` texture or gradient where appropriate
- Reference existing styles in `components/**/styles/` for exact conventions

---

## Component rules (`$1.tsx`)

```tsx
"use client"

import styles from "./styles/$1.module.css"
import { useState } from "react"
import { Button } from "@/components/ui/button"
import { SomeIconFromListBelow } from "lucide-react"

export default function $1() {
  // ─── MOCK (delete when real hook is connected) ────────────────────────────────
  const MOCK = {
    // ALL test data as one object
  }
  // ─────────────────────────────────────────────────────────────────────────────

  // 3. derived values

  // internal functions — ALWAYS traditional function syntax
  function handleSomeAction(params: { id: string }) {
    // ...
  }

  return (
    <div className={styles.window}>
      <div className={styles.titleBar}>
        <h2 className={styles.title}>{MOCK.title}</h2>
      </div>
      <div className={styles.content}>{/* main content */}</div>
    </div>
  )
}
```

## Lucide icons — Import only from this list. If the icon you need is not here, use the closest alternative that is. Never guess or invent a name.

- correct import { Sword, Shield, Coins } from "lucide-react"

Weapons: `Sword Swords Shield Axe Crosshair Target Skull BowArrow`  
Characters: `User Users Crown Trophy UserCheck UserX UserPlus`  
Buildings: `Castle Church Building Building2 House Landmark Flag`  
Fire/light: `Flame Sun Moon Sunrise Sunset Lamp`  
Resources: `Heart Coins Gem Diamond Backpack Package Barrel Vault`  
Tools: `Binoculars Anvil Amphora Pickaxe Hammer Shovel Wrench Anvil`  
Food: `Apple Wheat WheatOff Beef FlaskConical FlaskRound Droplets`  
Magic: `Biohazard Sparkles Zap WandSparkles Wand2 BookOpen ScrollText Eye Ghost`  
Map: `Map MapPin Compass Globe Mountain Trees Footprints Telescope Signpost`  
Camp: `Tent Bed Wind CloudRain Snowflake`  
UI: `X Check Shrink Info AlertTriangle Clock Hourglass ChevronDown ChevronUp`  
Ships/Travel: `Sailboat Anchor Ship ShipWheel`  
Strategy: `BrickWall BrickWallShield BrickWallFire ChessKing ChessRook ChessQueen Dice1 Dice6 Dices` Others:
`Thermometer`

## Rendering note

This component will be mounted inside one of the panel wrappers at `components/panels/**`.  
Do not add page-level layout — the panel provides positioning and z-index. "Focus on rendering" only UI and mock data,
funcionality leave for manual user correction.

## JSX conditionals — splitting rules

Never use ternary (? :) in JSX when either branch exceeds 3 lines.Instead:

1. Extract each branch into a named sub-component with early return
2. Sub-components live in the same file

## RECAP — never forget

- Create only 2 files game UI:
- `components/NewComponents/$1.tsx`
- `components/NewComponents/styles/$1.module.css`
- No Tailwind, no ternary > 3 lines
- MOCK inside component body flat object max 2 level of nesting, never in state
- Stub all handlers
