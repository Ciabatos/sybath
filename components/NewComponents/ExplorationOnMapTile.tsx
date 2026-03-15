"use client"

import { Button } from "@/components/ui/button"
import {
  Backpack,
  Binoculars,
  Castle,
  Clock,
  Compass,
  Crosshair,
  Flame,
  Heart,
  Moon,
  Shield,
  Tent,
  Thermometer,
} from "lucide-react"
import { useState } from "react"

import styles from "./styles/ExplorationOnMapTile.module.css"

export default function ExplorationOnMapTile() {
  const [selectedTab, setSelectedTab] = useState<string>("overview")
  const [isCampActive, setIsCampActive] = useState<boolean>(false)
  const [moraleLevel, setMoraleLevel] = useState<number>(3)
  const [vigilanceLevel, setVigilanceLevel] = useState<number>(2)

  const MOCK = {
    mapTileName: "Whispering Ridge",
    mapTileCoordinates: "[1456, 892]",
    mapTileTerrain: "Rolling Hills",
    mapTileRegion: "Eastern Expanse",
    playerLevel: 7,
    playerClass: "Knight",
    currentGold: 342,
    currentExperience: 1250,
    nextLevelExperience: 2000,

    hungerValue: 3,
    fatigueValue: 2,
    temperatureValue: 1,
    moraleValue: 4,
    vigilanceValue: 3,

    encumbranceCurrent: 18,
    encumbranceMax: 60,
    encumbranceLevel: "Light",

    dayNightCycle: "Daylight",
    timeUntilDawn: "N/A",
    timeElapsed: "5 days, 3 hours",

    availableActions: ["Scout Area", "Set Camp", "Rest Here", "Travel"],

    gatheredResources: [
      { id: "1", name: "Wild Apples", quantity: "8x", icon: "🍎" },
      { id: "2", name: "Grain Sacks", quantity: "3x", icon: "🌾" },
      { id: "3", name: "Herbal Tincture", quantity: "5x", icon: "🧪" },
    ],

    conditions: [
      { id: "1", name: "Steady Hands", value: "+2 Accuracy", icon: "⚔️" },
      { id: "2", name: "Clear Vision", value: "+3 Perception", icon: "👁️" },
    ],

    campfireEffects: [
      { id: "1", name: "Warmth & Light", value: "+5°C, -2 Fatigue" },
      { id: "2", name: "Morale Boost", value: "+3 Morale" },
      { id: "3", name: "Safe Haven", value: "-4x Ambush chance" },
    ],

    threatsNearby: [
      { id: "1", name: "Bandit Patrol", distance: "2 miles", danger: "Medium" },
      { id: "2", name: "Wild Boar Herd", distance: "0.5 miles", danger: "Low" },
    ],

    explorationProgress: 45,
    mapExplorationPercent: 67,
  }

  const encumbrancePercentage =
    MOCK.encumbranceMax === 0 ? 0 : Math.round((MOCK.encumbranceCurrent / MOCK.encumbranceMax) * 100)

  const experienceProgress =
    MOCK.nextLevelExperience === 0 ? 0 : Math.round((MOCK.currentExperience / MOCK.nextLevelExperience) * 100)

  function handleScoutArea() {
    console.log("Scouting area")
  }

  function handleSetCamp() {
    setIsCampActive(true)
  }

  function handleRestHere() {
    console.log("Resting here")
  }

  function handleTravel() {
    console.log("Traveling to next location")
  }

  function handleClose() {
    console.log("Closing exploration panel")
  }

  return (
    <div className={styles.panel}>
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
          <Castle className={styles.closeIcon} />
        </Button>
      </div>

      <div className={styles.content}>
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Player Status</h3>
          <div className={styles.playerStatusContainer}>
            <div className={styles.statusRow}>
              <span className={styles.statusLabel}>
                Level {MOCK.playerLevel} · {MOCK.playerClass}
              </span>
              <span className={styles.statusValue}>{MOCK.currentGold} gold</span>
            </div>
            <div className={styles.statusRow}>
              <span className={styles.statusLabel}>EXP</span>
              <span className={styles.statusValue}>
                {MOCK.currentExperience} / {MOCK.nextLevelExperience}
              </span>
            </div>
          </div>

          <div className={styles.statsContainer}>
            <div className={styles.statRow}>
              <Heart className={styles.statIcon} />
              <span className={styles.statLabel}>Hunger</span>
              <div className={styles.statValue}>{MOCK.hungerValue}/5</div>
              <div className={styles.statPips}>
                {[1, 2, 3, 4, 5].map(function (pip) {
                  return (
                    <div
                      key={pip}
                      className={pip <= MOCK.hungerValue ? styles.pipFilled : styles.pipEmpty}
                    />
                  )
                })}
              </div>
            </div>

            <div className={styles.statRow}>
              <Clock className={styles.statIcon} />
              <span className={styles.statLabel}>Fatigue</span>
              <div className={styles.statValue}>{MOCK.fatigueValue}/5</div>
              <div className={styles.statPips}>
                {[1, 2, 3, 4, 5].map(function (pip) {
                  return (
                    <div
                      key={pip}
                      className={pip <= MOCK.fatigueValue ? styles.pipFilled : styles.pipEmpty}
                    />
                  )
                })}
              </div>
            </div>

            <div className={styles.statRow}>
              <Thermometer className={styles.statIcon} />
              <span className={styles.statLabel}>Temperature</span>
              <div className={styles.statValue}>{MOCK.temperatureValue}/5</div>
              <div className={styles.statPips}>
                {[1, 2, 3, 4, 5].map(function (pip) {
                  return (
                    <div
                      key={pip}
                      className={pip <= MOCK.temperatureValue ? styles.pipFilled : styles.pipEmpty}
                    />
                  )
                })}
              </div>
            </div>

            <div className={styles.statRow}>
              <Castle className={styles.statIcon} />
              <span className={styles.statLabel}>Morale</span>
              <div className={styles.statValue}>{MOCK.moraleValue}/5</div>
              <div className={styles.statPips}>
                {[1, 2, 3, 4, 5].map(function (pip) {
                  return (
                    <div
                      key={pip}
                      className={pip <= MOCK.moraleValue ? styles.pipFilled : styles.pipEmpty}
                    />
                  )
                })}
              </div>
            </div>

            <div className={styles.statRow}>
              <Shield className={styles.statIcon} />
              <span className={styles.statLabel}>Vigilance</span>
              <div className={styles.statValue}>{MOCK.vigilanceValue}/5</div>
              <div className={styles.statPips}>
                {[1, 2, 3, 4, 5].map(function (pip) {
                  return (
                    <div
                      key={pip}
                      className={pip <= MOCK.vigilanceValue ? styles.pipFilled : styles.pipEmpty}
                    />
                  )
                })}
              </div>
            </div>
          </div>

          <div className={styles.encumbranceContainer}>
            <Backpack className={styles.encumbranceIcon} />
            <span className={styles.encumbranceLabel}>
              {MOCK.encumbranceCurrent} / {MOCK.encumbranceMax}
            </span>
            <span className={styles.encumbranceStatus}>{MOCK.encumbranceLevel}</span>
            <span className={styles.encumbrancePercentage}>{encumbrancePercentage}%</span>
          </div>

          <div className={styles.timeContainer}>
            <Moon className={styles.dayNightIcon} />
            <span className={styles.dayNightValue}>{MOCK.dayNightCycle}</span>
            <Clock className={styles.timeIcon} />
            <span className={styles.timeValue}>{MOCK.timeElapsed}</span>
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Camp Status</h3>
          <div className={styles.campStatusContainer}>
            {isCampActive ? (
              <div className={styles.activeCamp}>
                <Tent className={styles.campIcon} />
                <span className={styles.campName}>Camp Established</span>
              </div>
            ) : (
              <div className={styles.inactiveCamp}>
                <Tent className={styles.campIcon} />
                <span className={styles.campName}>No Camp Active</span>
              </div>
            )}

            <div className={styles.campfireContainer}>
              <Flame className={styles.flameIcon} />
              <span className={styles.campfireName}>Campfire</span>
            </div>

            {MOCK.campfireEffects.map(function (effect) {
              return (
                <div
                  key={effect.id}
                  className={styles.effectBadge}
                >
                  <Flame className={styles.effectIcon} />
                  <span className={styles.effectName}>{effect.name}</span>
                  <span className={styles.effectValue}>{effect.value}</span>
                </div>
              )
            })}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Conditions</h3>
          <div className={styles.conditionsContainer}>
            {MOCK.conditions.map(function (condition) {
              return (
                <div
                  key={condition.id}
                  className={styles.condition}
                >
                  <span className={styles.conditionEmoji}>{condition.icon}</span>
                  <span className={styles.conditionName}>{condition.name}</span>
                  <span className={styles.conditionValue}>{condition.value}</span>
                </div>
              )
            })}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Threats Nearby</h3>
          <div className={styles.threatsContainer}>
            {MOCK.threatsNearby.map(function (threat) {
              return (
                <div
                  key={threat.id}
                  className={styles.threatRow}
                >
                  <Crosshair className={styles.threatIcon} />
                  <span className={styles.threatName}>{threat.name}</span>
                  <span className={styles.threatDistance}>{threat.distance}</span>
                  <span className={styles.threatDanger}>{threat.danger}</span>
                </div>
              )
            })}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Resources Gathered</h3>
          <div className={styles.resourcesContainer}>
            {MOCK.gatheredResources.map(function (resource) {
              return (
                <div
                  key={resource.id}
                  className={styles.resourceRow}
                >
                  <span className={styles.resourceEmoji}>{resource.icon}</span>
                  <span className={styles.resourceName}>{resource.name}</span>
                  <span className={styles.resourceQuantity}>{resource.quantity}</span>
                </div>
              )
            })}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Exploration Progress</h3>
          <div className={styles.explorationContainer}>
            <Binoculars className={styles.explorationIcon} />
            <span className={styles.explorationLabel}>{MOCK.explorationProgress}% explored</span>
            <Compass className={styles.compassIcon} />
            <span className={styles.mapExplorationLabel}>{MOCK.mapExplorationPercent}% map known</span>
          </div>

          <div className={styles.progressBarContainer}>
            <div
              className={styles.progressBarFill}
              style={{ width: `${experienceProgress}%` }}
            />
          </div>
        </section>

        <div className={styles.actionButtons}>
          <Button
            className={styles.explorationActionButton}
            onClick={handleScoutArea}
          >
            <Binoculars className={styles.buttonIcon} />
            Scout Area
          </Button>
          <Button
            className={styles.explorationActionButton}
            onClick={handleSetCamp}
          >
            <Tent className={styles.buttonIcon} />
            Set Camp
          </Button>
          <Button
            className={styles.explorationActionButton}
            variant='outline'
            onClick={handleRestHere}
          >
            <Moon className={styles.buttonIcon} />
            Rest Here
          </Button>
          <Button
            className={styles.explorationActionButton}
            variant='outline'
            onClick={handleTravel}
          >
            <Compass className={styles.buttonIcon} />
            Travel
          </Button>
        </div>

        {isCampActive && (
          <p className={styles.hintText}>Your camp is established. Rest to recover fatigue and gain experience.</p>
        )}

        {!isCampActive && (
          <div className={styles.emptyState}>
            <Tent className={styles.emptyStateIcon} />
            <p>Press "Set Camp" to establish a camp at this location.</p>
          </div>
        )}
      </div>
    </div>
  )
}
