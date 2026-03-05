"use client"

import { Button } from "@/components/ui/button"
import { AlertCircle, ArrowRight, Clock, Flame, Hand, Loader, Sparkles, Sunrise, Tent, User, UserCheck } from "lucide-react"
import { useState } from "react"
import styles from "./styles/PlayerCamp.module.css"

export default function PlayerCamp() {
  const [isSetupComplete, setIsSetupComplete] = useState(false)
  const [isReadyToRest, setIsReadyToRest] = useState(false)
  const [isCampfireActive, setIsCampfireActive] = useState(false)
  const [isEncumbered, setIsEncumbered] = useState(false)
  const [timeRemaining, setTimeRemaining] = useState(60)

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

    gainedConditions: [
      { name: "Rested", icon: "☀️", description: "+2 Morale, -1 Fatigue" },
      { name: "Hungry", icon: "😴", description: "Stomach growls occasionally" },
    ],

    campfireEffects: [
      { name: "Light & Warmth", value: "+10°C" },
      { name: "Morale Boost", value: "+5%" },
      { name: "Safe Haven", value: "-3x Ambush chance" },
    ],

    availableActions: ["Move Out", "Wake Up", "Prepare Meal", "Tend Fires"],
    pendingActions: [
      { name: "Watch Fires", status: "Ready" },
      { name: "Practice Arms", status: "Ready" },
      { name: "Study Maps", status: "Ready" },
    ],

    gatheredResources: [
      { name: "Dripping Moss", quantity: "1x", icon: "🌿" },
      { name: "Forest Bream", quantity: "2x", icon: "🐟" },
      { name: "Hard Wood", quantity: "1x", icon: "🪵" },
    ],

    timeElapsed: "2 days, 4 hours",
  }

  const encumbrancePercentage = Math.round(
    (!MOCK.currentEncumbrance || MOCK.maxEncumbrance === 0)
      ? 0
      : (MOCK.currentEncumbrance / MOCK.maxEncumbrance) * 100
  )
  const isHunted = MOCK.playerTemperature >= 2
  const isHungerCritical = MOCK.playerHunger >= 3
  const isTimeCritical = timeRemaining <= 30

  function handleSetupCamp(data: { mapTileName: string; timeUntilDawn: string; playerCondition: string }) {
    console.log("Setting up camp on:", data)
  }

  function handleWakeUp() {
    console.log("Waking up from camp")
    setIsSetupComplete(false)
    setIsReadyToRest(false)
  }

  function handleMoveOut() {
    console.log("Moving out from camp")
  }

  function handleCampfireAdjustment(adjustment: "add" | "reduce" | "maintain") {
    console.log("Adjusting campfire:", adjustment)
  }

  function handlePrepareMeals(foodType: string) {
    console.log("Preparing meal:", foodType)
  }

  function handleWatchFire() {
    console.log("Watching campfire")
  }

  function handlePracticeArms() {
    console.log("Practicing arms")
  }

  function handleClose() {
    console.log("Closing camp interface")
  }

  return (
    <div>
    <div className={styles.panel}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>{MOCK.mapTileName}</h2>
          <p className={styles.subTitle}>{MOCK.mapTileTerrain}</p>
          <span className={styles.coordinates}>{MOCK.mapTileCoordinates}</span>
        </div>
        <Button
          onClick={handleClose}
          variant="ghost"
          size="icon"
          className={styles.closeButton}
        >
          <AlertCircle className={styles.closeIcon} />
        </Button>
      </div>

      <div className={styles.content}>
        <section className={styles.section}>
          <div className={styles.restingContainer}>
            <div className={styles.restingStatus}>
              <div className={styles.restingIndicator}>
                <Tent className={styles.readyIcon} />
                <div className={styles.restingInfo}>
                  <span className={styles.restingName}>Camping</span>
                  {isReadyToRest && <span className={styles.restingEffect}>Ready to rest</span>}
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Conditions</h3>
          <div className={styles.conditionsContainer}>
            {isHunted && (
              <div className={styles.condition}>
                <Sunrise className={styles.conditionIcon} />
                <span className={styles.conditionName}>Hunted</span>
                <span className={styles.conditionValue}>{isHunted ? "✓" : "✗"}</span>
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

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Encumbrance</h3>
          <div className={styles.encumbranceContainer}>
            <Hand className={styles.encumbranceIcon} />
            <div className={styles.encumbranceInfo}>
              <span className={styles.encumbranceLabel}>Current</span>
              <span className={styles.encumbranceValue}>
                {MOCK.currentEncumbrance} / {MOCK.maxEncumbrance}
              </span>
              <span className={styles.encumbranceStatus}>{MOCK.encumbranceLevel}</span>
            </div>
            <div className={styles.encumbrancePercentage}>{encumbrancePercentage}</div>
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Campfire</h3>
          <div className={styles.campfireContainer}>
            <div
              className={styles.campfireIconWrapper}
              style={{
                background: `linear-gradient(45deg, rgba(255,165,0,0.1) 25%,transparent 25%,transparent 50%,rgba(255,165,0,0.1) 50%,rgba(255,165,0,0.1) 75%,transparent 75%,transparent 100%); background-size: 20px 20px;`
              }}
            />
            <div className={styles.campfireName}>
              <Flame className={styles.flameAnimation} />
              <br />
              Campfire ({isCampfireActive ? "Active" : "Unlit"})
            </div>
          </div>
          <div className={styles.conditionsContainer}>
            {MOCK.campfireEffects.map((effect, index) => (
              <div
                key={index}
                className={styles.condition}
                data-campfire-effect={true}
              >
                <AlertCircle className={styles.conditionIcon} />
                <span className={styles.conditionName}>{effect.name}</span>
                <span className={styles.conditionValue}>{effect.value}</span>
              </div>
            ))}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Time & Cycle</h3>
          <div className={styles.dayNightContainer}>
            <div className={styles.dayNightCell day}>Day</div>
            <div className={styles.dayNightCell night}>Night</div>
          </div>
          <div className={styles.timeRemainingContainer}>
            <Clock className={styles.timeRemainingIcon} />
            <span className={styles.timeRemainingValue}>{timeRemaining} min</span>
            <span className={styles.timeRemainingLabel}>until dawn</span>
          </div>
          <span className={styles.timeRemainingLabel}>
            Camping since: {MOCK.campingSince}
          </span>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>{MOCK.timeElapsed}</h3>
          <div className={styles.restingProgress}>
            <Loader className={styles.restingSpinner} />
            <span className={styles.restingTime}>
              {isReadyToRest ? "Ready to rest" : "Resting time remaining..."}
            </span>
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Effects</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.gainedConditions.map((condition, index) => (
              <div
                key={index}
                className={styles.condition}
                data-condition-type="gained"
              >
                <span className={styles.conditionIcon}>{condition.icon}</span>
                <span className={styles.conditionName}>{condition.name}</span>
                <span className={styles.conditionTooltip}>
                  <AlertCircle className={styles.conditionIcon} size={12} />
                  <span className={styles.conditionValue}>{condition.description}</span>
                </span>
              </div>
            ))}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Actions</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.availableActions.map((action, index) => (
              <div
                key={index}
                className={styles.condition}
                data-action-type="available"
              >
                <ArrowRight className={styles.conditionIcon} />
                <span className={styles.conditionName}>{action}</span>
              </div>
            ))}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Pending Activity</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.pendingActions.map((action, index) => (
              <div
                key={index}
                className={styles.condition}
                data-action-type="pending"
              >
                <Sparkles className={styles.conditionIcon} />
                <span className={styles.conditionName}>{action.name}</span>
                <span className={styles.conditionValue}>{action.status}</span>
              </div>
            ))}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Resources Gathered</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.gatheredResources.map((resource, index) => (
              <div
                key={index}
                className={styles.condition}
                data-resource-type="gathered"
              >
                <span className={styles.conditionIcon}>{resource.icon}</span>
                <span className={styles.conditionName}>{resource.name}</span>
                <span className={styles.conditionValue}>{resource.quantity}</span>
              </div>
            ))}
          </div>
        </section>

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
            variant="outline"
            disabled={!isSetupComplete}
          >
            Setup Camp
          </Button>
          <Button
            className={styles.campActionButton}
            variant="outline"
            disabled={!isSetupComplete}
          >
            Adjust Fire
          </Button>
        </div>

        {isSetupComplete && (
          <div className={styles.hintText}>
            Stay alert! The fire will extinguish when you move out.
          </div>
        )}

        {!isSetupComplete && (
          <div className={styles.emptyState}>
            <Tent className={styles.emptyStateIcon} />
            <p>Press "Setup Camp" to set up camp on this map tile.</p>
          </div>
        )}
      </div>
    </div>
  )
}
