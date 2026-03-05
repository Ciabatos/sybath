"use client"

import { Button } from "@/components/ui/button"
import { Spinner } from "@/components/ui/spinner"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { AlertCircle, ChevronRight, Compass, Gem, Map as MapIcon, Shield, Star, Sword } from "lucide-react"
import { useEffect, useState } from "react"
import styles from "./styles/ExplorationOnMapTile.module.css"

// Mock exploration data structure - delete when real hook is available
type TExplorationData = {
  tileId: string
  terrainName: string
  landscapeName: string
  explorationDifficulty: number
  potentialRewards: Array<{
    itemId: number
    name: string
    rarity: number
    quantity: number
  }>
  explorationRisks: {
    riskLevel: number
    riskName: string
    probability: number
  }[]
  successChances: {
    findRareResource: number
    discoverSecret: number
    encounterDanger: number
  }
  isExplored: boolean
  explorationNotes: string
}

export default function ExplorationOnMapTile() {
  const { resetModalRightCenter } = useModalRightCenter()

  // Mock exploration data
  const [explorationData, setExplorationData] = useState<TExplorationData | null>(null)
  const [isExploring, setIsExploring] = useState(false)
  const [explorationProgress, setExplorationProgress] = useState(0)

  // Mock data generation - delete when real data is available
  useEffect(() => {
    setExplorationData({
      tileId: "mock-tile-001",
      terrainName: "Mountainous Region",
      landscapeName: "Alpine Valley",
      explorationDifficulty: 3,
      potentialRewards: [
        { itemId: 1, name: "Ancient Map Fragment", rarity: 3, quantity: 1 },
        { itemId: 2, name: "Treasure Map", rarity: 4, quantity: 1 },
        { itemId: 3, name: "Rare Herbs", rarity: 2, quantity: 10 },
      ],
      explorationRisks: [
        { riskLevel: 2, riskName: "Wild Animals", probability: 30 },
        { riskLevel: 3, riskName: "Ambush", probability: 20 },
        { riskLevel: 4, riskName: "Treasure Hunt", probability: 15 },
      ],
      successChances: {
        findRareResource: 25,
        discoverSecret: 15,
        encounterDanger: 40,
      },
      isExplored: false,
      explorationNotes: "",
    })
  }, [])

  // Update explorationProgress when explorationData changes
  useEffect(() => {
    if (explorationData) {
      setExplorationProgress(0)
    }
  }, [explorationData])

  useEffect(() => {
    if (isExploring) {
      const interval = setInterval(() => {
        setExplorationProgress((prev) => {
          if (prev >= 100) {
            clearInterval(interval)
            handleFinishExploration()
            return 100
          }
          return prev + 2
        })
      }, 50)
      return () => clearInterval(interval)
    }
  }, [isExploring])

  function handleFinishExploration() {
    setIsExploring(false)
    resetModalRightCenter()
    setExplorationProgress(0)
  }

  function handleCancelExplore() {
    setIsExploring(false)
    resetModalRightCenter()
    setExplorationProgress(0)
  }

  function handleExplore() {
    if (!isExploring) {
      setIsExploring(true)
    }
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <div className={styles.header}>
          <div className={styles.titleSection}>
            <h2 className={styles.title}>
              <Compass className={styles.titleIcon} />
              Explore Tile
            </h2>
            <div className={styles.tileInfo}>
              <span className={styles.terrainName}>{explorationData?.terrainName}</span>
              <span className={styles.landscapeName}>{explorationData?.landscapeName}</span>
              <span className={styles.coordinates}>Tile {explorationData?.tileId}</span>
            </div>
          </div>
          <Button
            onClick={() => {
              resetModalRightCenter()
            }}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
          >
            <AlertCircle className={styles.closeIcon} />
          </Button>
        </div>

        <div className={styles.content}>
          {/* Exploration Status */}
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>
              <MapIcon className={styles.sectionIcon} />
              Current Status
            </h3>
            <div className={styles.statusContainer}>
              {isExploring ? (
                <div className={styles.explorationInProgress}>
                  <div className={styles.progressContainer}>
                    <Spinner className={styles.progressSpinner} />
                    <div className={styles.progressText}>
                      <span className={styles.progressLabel}>Exploring... {explorationProgress}%</span>
                      <span className={styles.progressHint}>Discovering secrets of this land...</span>
                    </div>
                  </div>
                  <div
                    className={styles.difficultyBadge}
                    data-level={explorationData?.explorationDifficulty}
                  >
                    <Star className={styles.difficultyIcon} />
                    <span className={styles.difficultyText}>Difficulty {explorationData?.explorationDifficulty}/5</span>
                  </div>
                </div>
              ) : (
                <div className={styles.statusReady}>
                  <div className={styles.readyIndicator}>✓ Ready to Explore</div>
                </div>
              )}
            </div>
          </section>

          {/* Potential Rewards */}
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>
              <Gem className={styles.sectionIcon} />
              Potential Rewards
            </h3>
            <div className={styles.rewardList}>
              {explorationData?.potentialRewards.map((reward, _, arr) => (
                <div
                  key={reward.itemId}
                  className={styles.rewardItem}
                >
                  <div className={styles.rewardIcon}>💎</div>
                  <div className={styles.rewardInfo}>
                    <span className={styles.rewardName}>{reward.name}</span>
                    <div className={styles.rewardRarity}>
                      {[1, 2, 3, 4, 5].map((level, i) => (
                        <span
                          key={i}
                          className={styles.rarityDot}
                          style={{
                            backgroundColor: level <= reward.rarity ? "#c89a4a" : "#4a3728",
                          }}
                        ></span>
                      ))}
                    </div>
                  </div>
                  <ChevronRight className={styles.rewardArrow} />
                </div>
              ))}
            </div>
          </section>

          {/* Exploration Risks */}
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>
              <Sword className={styles.sectionIcon} />
              Potential Risks
            </h3>
            <div className={styles.riskList}>
              {explorationData?.explorationRisks.map((risk, index) => (
                <div
                  key={index}
                  className={styles.riskItem}
                >
                  <div className={styles.riskLevel}>{risk.riskLevel}</div>
                  <div className={styles.riskName}>{risk.riskName}</div>
                  <div className={`${styles.riskProbability} ${riskBadgeClass(risk)}`}>{risk.probability}%</div>
                </div>
              ))}
            </div>
          </section>

          {/* Success Chances */}
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>
              <Shield className={styles.sectionIcon} />
              Success Chances
            </h3>
            <div className={styles.chancesContainer}>
              <div className={styles.chanceItem}>
                <span className={styles.chanceLabel}>Find Rare Resource:</span>
                <span className={styles.chanceValue}>{explorationData?.successChances.findRareResource}%</span>
                <div
                  className={styles.chanceBar}
                  style={{
                    width: `${explorationData?.successChances.findRareResource}%`,
                  }}
                ></div>
              </div>
              <div className={styles.chanceItem}>
                <span className={styles.chanceLabel}>Discover Secret:</span>
                <span className={styles.chanceValue}>{explorationData?.successChances.discoverSecret}%</span>
                <div
                  className={styles.chanceBar}
                  style={{
                    width: `${explorationData?.successChances.discoverSecret}%`,
                  }}
                ></div>
              </div>
              <div className={styles.chanceItem}>
                <span className={styles.chanceLabel}>Encounter Danger:</span>
                <span
                  className={`${styles.chanceValue} ${
                    (explorationData?.successChances?.encounterDanger ?? 0) > 35 ? "text-orange-400" : ""
                  }`}
                >
                  {explorationData?.successChances.encounterDanger}%
                </span>
                <div
                  className={styles.chanceBar}
                  style={{
                    width: `${explorationData?.successChances.encounterDanger}%`,
                    backgroundColor:
                      (explorationData?.successChances?.encounterDanger ?? 0) > 35 ? "#f87171" : "#c89a4a",
                  }}
                ></div>
              </div>
            </div>
          </section>

          {/* Action Buttons */}
          <section className={styles.section}>
            <div className={styles.actionButtons}>
              {isExploring ? (
                <>
                  <Button
                    className={styles.actionButton}
                    variant='outline'
                    onClick={() => {
                      handleCancelExplore()
                    }}
                  >
                    Stop Exploration
                  </Button>
                </>
              ) : (
                <Button
                  className={styles.exploreButton}
                  variant='default'
                  size='lg'
                  onClick={() => {
                    handleExplore()
                  }}
                >
                  <Compass className={styles.exploreIcon} />
                  Explore This Tile
                </Button>
              )}
            </div>
            <div className={styles.explorerInfo}>
              <span>Estimated duration: 1-3 actions</span>
            </div>
          </section>

          {/* Notes */}
          {explorationData?.explorationNotes && (
            <section className={styles.section}>
              <h3 className={styles.sectionTitle}>Explorer&apos;s Notes</h3>
              <p className={styles.notesText}>{explorationData.explorationNotes}</p>
            </section>
          )}
        </div>
      </div>
    </div>
  )
}

// Helper function for risk badge styling
function riskBadgeClass(risk: { riskLevel: number }) {
  if (risk.riskLevel <= 2) return "text-green-400"
  if (risk.riskLevel === 3) return "text-yellow-400"
  if (risk.riskLevel === 4) return "text-orange-400"
  if (risk.riskLevel === 5) return "text-red-400"
  return "text-red-400"
}
