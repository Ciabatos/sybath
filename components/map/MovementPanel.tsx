// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useModalBottomCenter } from "@/methods/hooks/modals/useModalBottomCenter"
import { usePlayerMovement, usePlayerMovementPlanned } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { X } from "lucide-react"
import { useEffect, useState } from "react"
import styles from "./styles/MovementPanel.module.css"

export default function MovementPanel() {
  const { resetModalBottomCenter } = useModalBottomCenter()
  const playerMovementPlanned = usePlayerMovementPlanned()
  const { clickedMapTile } = useMapTileActions()
  const [isMoving, setIsMoving] = useState(true)
  const { selectPlayerPathToClickedTile, goSelectedPlayerPath, resetPlayerMovementPlanned } = usePlayerMovement()

  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    if (!isMounted && playerMovementPlanned) {
      setIsMounted(true)
      return
    }
    if (isMoving) {
      selectPlayerPathToClickedTile()
    }
  }, [clickedMapTile])

  function handleConfirmMove() {
    if (isMoving) {
      goSelectedPlayerPath()
      closeMovementPanel()
    }
  }

  function closeMovementPanel() {
    resetPlayerMovementPlanned()
    setIsMoving(false)
    setIsMounted(false)
    resetModalBottomCenter()
  }
  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={closeMovementPanel}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>

        <>
          <Button
            className={styles.actionButton}
            onClick={handleConfirmMove}
          >
            Confirm Move
          </Button>

          <Button
            className={styles.actionButton}
            onClick={closeMovementPanel}
          >
            Cancel Move
          </Button>
        </>
      </div>
    </div>
  )
}
