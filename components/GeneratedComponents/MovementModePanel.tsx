"use client"

import { Button } from "@/components/ui/button"
import { usePlayerExploration } from "@/methods/hooks/players/composite/usePlayerExploration"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { Hand, X } from "lucide-react"
import { useEffect, useState } from "react"
import { GiBigDiamondRing, GiCrystalBall, GiDropWeapon } from "react-icons/gi"
import styles from "./styles/MovementModePanel.module.css"

interface MovementModePanelProps {
  isOpen: boolean
  onClose: () => void
}

export default function MovementModePanel({ isOpen, onClose }: MovementModePanelProps) {
  // ── MOVEMENT / EXPLORATION LOGIC  ──────────────────────────────────────────
  const { selectPlayerPathToClickedTile, selectPlayerPathAndMovePlayerToClickedTile, resetPlayerMovementPlanned } =
    usePlayerMovement()
  const { exploreClickedTile } = usePlayerExploration()
  const { clickedMapTile } = useMapTileActions()
  const { playerMovement } = usePlayerMovement()
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [progressPercentage, setProgressPercentage] = useState<number>(0)
  const [isMoving, setIsMoving] = useState(false)
  const [isExploring, setIsExploring] = useState(false)

  useEffect(() => {
    if (!isOpen) {
      setIsMoving(false)
      setIsExploring(false)
      resetPlayerMovementPlanned()
    }
  }, [isOpen])

  useEffect(() => {
    if (isOpen && (isMoving || isExploring)) {
      selectPlayerPathToClickedTile()
    }
  }, [clickedMapTile])

  function handleMove() {
    if (!isMoving) {
      setIsMoving(true)
      selectPlayerPathToClickedTile()
    }
  }

  function handleConfirmMove() {
    if (isMoving) {
      setIsMoving(false)
      selectPlayerPathAndMovePlayerToClickedTile()
    }
  }

  function handleCancelMove() {
    setIsMoving(false)
    resetPlayerMovementPlanned()
  }

  function handleExplore() {
    if (!isExploring) {
      setIsExploring(true)
      selectPlayerPathToClickedTile()
    }
  }

  function handleConfirmExplore() {
    if (isExploring) {
      setIsExploring(false)
      exploreClickedTile()
      resetPlayerMovementPlanned()
    }
  }

  function handleCancelExplore() {
    setIsExploring(false)
    resetPlayerMovementPlanned()
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────

  const nextMove = Object.values(playerMovement).sort((a, b) => a.order - b.order)[0]

  const totalMoveCost = Object.values(playerMovement).reduce((acc, movement) => acc + movement.totalMoveCost, 0)
  // ── GUARD ──────────────────────────────────────────────────────────────────
  if (!isOpen) return null

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>Movement Mode</h2>
          <p className={styles.subTitle}>Travel Journal · {nextMove.moveCost} minutes to destination</p>
          <span className={styles.coordinates}>
            {nextMove.x}, {nextMove.y}
          </span>
        </div>
        <Button
          onClick={onClose}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <X className={styles.closeIcon} />
        </Button>
      </div>

      {/* CONTENT */}
      <div className={styles.content}>
        {/* Movement Progress */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Journey Progress</h3>
          <div className={styles.progressContainer}>
            <span className={styles.statusIndicator}>In Transit</span>
            <div className={styles.progressBar}></div>
            <div className={styles.progressInfo}>
              <span>{/* {MOCK.totalDistance - MOCK.remainingDistance}/{MOCK.totalDistance} units */}</span>
              <span>{Math.round(progressPercentage)}%</span>
            </div>
          </div>
        </section>

        {/* Costs */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Travel Costs</h3>
          <div className={styles.costsContainer}>
            <div className={styles.costItem}>
              <GiDropWeapon />
              <span>Movement: 4 pts</span>
            </div>
            <div className={`${styles.costItem} ${styles.goldText}`}>
              <GiBigDiamondRing />
              <span>Gold: 4</span>
            </div>
            <div className={`${styles.costItem} ${styles.manaText}`}>
              <GiCrystalBall />
              <span>Mana: 4</span>
            </div>
            <div className={`${styles.costItem} ${styles.staminaText}`}>
              <Hand />
              <span>Stamina: 4</span>
            </div>
          </div>
        </section>

        {/* Terrain Effects */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Terrain Effects</h3>
          <div className={styles.terrainContainer}>
            {Object.values(playerMovement).map(function (terrain) {
              return (
                <div
                  key={terrain.order + `terrainEffect`}
                  className={styles.terrainItem}
                >
                  <span>dasdad</span>
                  <span className={styles.terrainModifier}>
                    {`2x`}
                    {`3x`}
                    {`3x`}
                    {`+3x`}
                  </span>
                </div>
              )
            })}
          </div>
        </section>

        {/* Action Buttons – Move / Explore */}
        <section className={styles.section}>
          <div className={styles.actionButtons}>
            {/* Ruch */}
            {isMoving ? (
              <>
                <Button
                  className={styles.actionButton}
                  variant='outline'
                  onClick={handleConfirmMove}
                >
                  Confirm Move
                </Button>
                <Button
                  className={styles.actionButton}
                  variant='outline'
                  onClick={handleCancelMove}
                >
                  Cancel Move
                </Button>
              </>
            ) : !isExploring ? (
              <Button
                className={styles.actionButton}
                variant='outline'
                onClick={handleMove}
              >
                Move Here
              </Button>
            ) : null}

            {/* Eksploracja */}
            {isExploring ? (
              <>
                <Button
                  className={styles.actionButton}
                  variant='outline'
                  onClick={handleConfirmExplore}
                >
                  Confirm Explore
                </Button>
                <Button
                  className={styles.actionButton}
                  variant='outline'
                  onClick={handleCancelExplore}
                >
                  Cancel Explore
                </Button>
              </>
            ) : !isMoving ? (
              <Button
                className={styles.actionButton}
                variant='outline'
                onClick={handleExplore}
              >
                Explore Here
              </Button>
            ) : null}
          </div>
        </section>
      </div>
    </div>
  )
}
