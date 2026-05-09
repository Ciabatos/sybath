// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import ConfirmMoveButton from "@/components/map/ConfirmMoveButton"
import { Button } from "@/components/ui/button"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { X } from "lucide-react"
import { useEffect, useState } from "react"
import styles from "./styles/MovementPanel.module.css"

export default function MovementPanel() {
  const { clickedMapTile } = useMapTileActions()
  const { isMoving, selectPlayerPathToClickedTile, closeMovementPanel } = usePlayerMovement()
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    if (!isMounted && isMoving) {
      setIsMounted(true)
      return
    }
    if (isMoving) {
      selectPlayerPathToClickedTile()
    }
  }, [clickedMapTile])

  function closeMovement() {
    setIsMounted(false)
    closeMovementPanel()
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={closeMovement}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>

        <>
          <ConfirmMoveButton onClose={closeMovement} />

          <Button
            className={styles.actionButton}
            onClick={closeMovement}
          >
            Cancel Move
          </Button>
        </>
      </div>
    </div>
  )
}
