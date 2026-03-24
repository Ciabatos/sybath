"use client"

import { Button } from "@/components/ui/button"
import { usePlayerExploration } from "@/methods/hooks/players/composite/usePlayerExploration"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { X } from "lucide-react"
import { useEffect, useState } from "react"
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
  }, [clickedMapTile, playerMovement])

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
  const lastMove = Object.values(playerMovement).sort((a, b) => b.order - a.order)[0]

  const totalMoveCost = Object.values(playerMovement).reduce((acc, movement) => acc + movement.totalMoveCost, 0)
  const path = Object.values(playerMovement)
    .sort((a, b) => a.order - b.order)
    .map((p) => ({ x: p.x, y: p.y }))
  // ── GUARD ──────────────────────────────────────────────────────────────────
  if (!isOpen) return null

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>Movement Mode</h2>
          <p>Travel Journal</p>
          <p className={styles.subTitle}>
            {nextMove.moveCost} minutes to next tile
            <span className={styles.coordinates}>
              {nextMove.x}, {nextMove.y}
            </span>
          </p>
          <p className={styles.subTitle}>
            {totalMoveCost} minutes to destination
            <span className={styles.coordinates}>
              {lastMove.x}, {lastMove.y}
            </span>
          </p>
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
