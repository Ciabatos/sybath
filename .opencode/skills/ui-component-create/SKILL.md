---
name: ui-component-create
description:
  World-class game UI design expertise combining the clarity of Nintendo's UI philosophy, the immersive diegetic
  interfaces of Dead Space and Metroid Prime, and the competitive readability principles from esports titles. Game UI is
  the invisible bridge between player intent and game response.  Great game UI serves the player without breaking
  immersion. It communicates critical information at a glance during intense action, guides new players without
  patronizing veterans, and adapts gracefully from 4K monitors to handheld screens and from keyboard to touch to
  controller. The best game UI designers understand that every pixel of screen space is sacred - borrowed from the game
  world itself. Use when "game ui, game interface, hud design, heads up display, game menu, inventory ui, health bar,
  stamina bar, game hud, minimap, crosshair, reticle, button prompt, controller ui, gamepad navigation, diegetic
  interface, in-world ui, quest tracker, damage numbers, cooldown indicator, radial menu, game tooltip, game-ui, hud,
  game-interface, game-menu, controller-ui, diegetic, game-design, accessibility, console, mobile-games" mentioned.
---

Great game UI is the invisible bridge between player intent and game response. Every pixel is borrowed from the game
world. This skill produces complete, interactive, visually immersive components — not boilerplate shells. Dark Fantasy
RPG — UI Component Skill Dark fantasy UI is not decoration. It is evidence. Evidence that something terrible happened
here, that the world is decaying, that the player is barely holding on. Every panel should feel like it was found, not
built. Stone-carved headings. Ink-bled text. Gold that has long since tarnished. Borders that crack. Flames that could
go out. The player's eye must find critical info in under 300ms during combat. Design for that constraint first, then
layer atmosphere on top — never the reverse.

## Reference how components should look ComponentName.tsx template

```tsx
"use client"

import { Button } from "@/components/ui/button"
import { AlertCircle, ArrowRight, Clock, Flame, Hand, Loader, Sparkles, Sunrise, Tent, UserCheck } from "lucide-react"
import { useState } from "react"
import styles from "./styles/ComponentName.module.css"

export default function ComponentName() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [isSetupComplete, setIsSetupComplete] = useState<boolean>(false)
  const [isReadyToRest, setIsReadyToRest] = useState<boolean>(false)
  const [isCampfireActive, setIsCampfireActive] = useState<boolean>(false)
  const [isEncumbered, setIsEncumbered] = useState<boolean>(false)
  const [timeRemaining, setTimeRemaining] = useState<number>(60)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    mapTileName: "The Weeping Woods",
    mapTileCoordinates: "[1247, 892]",
    mapTileTerrain: "Forest",
    mapTileRegion: "Northern Marches",

    playerHunger: 4,
    playerFatigue: 3,
    playerTemperature: 2,
    currentEncumbrance: 12,
    maxEncumbrance: 50,
    encumbranceLevel: "Light",

    campingSince: "2d 4h",
    dayNightCycle: "Evening",
    timeUntilDawn: "6h 23m",
    timeElapsed: "2 days, 4 hours",

    gainedConditions: [
      { id: "1", name: "Rested", icon: "☀️", description: "+2 Morale, -1 Fatigue" },
      { id: "2", name: "Hungry", icon: "😴", description: "Stomach growls occasionally" },
    ],

    campfireEffects: [
      { id: "1", name: "Light & Warmth", value: "+10°C" },
      { id: "2", name: "Morale Boost", value: "+5%" },
      { id: "3", name: "Safe Haven", value: "-3x Ambush chance" },
    ],

    availableActions: ["Move Out", "Wake Up", "Prepare Meal", "Tend Fires"],

    pendingActions: [
      { id: "1", name: "Watch Fires", status: "Ready" },
      { id: "2", name: "Practice Arms", status: "Ready" },
      { id: "3", name: "Study Maps", status: "Ready" },
    ],

    gatheredResources: [
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
