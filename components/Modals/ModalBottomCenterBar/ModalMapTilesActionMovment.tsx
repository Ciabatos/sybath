"use client"
import styles from "@/components/Modals/ModalBottomCenterBar/styles/ModalMapTilesActionMovment.module.css"
import { useActionMapTilesMovement } from "@/methods/hooks/playerMapTilesActions/useActionMapTilesMovement"

export default function ModalMapTilesActionMovment() {
  const { startingPoint, endingPoint, handleButtonMove, handleButtonCancel } = useActionMapTilesMovement()

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Tile to move to from tiles</p>
          <p>
            Movment path : {startingPoint?.mapTile.x}, {startingPoint?.mapTile.y} to {endingPoint?.mapTile.x}, {endingPoint?.mapTile.y}
          </p>
        </div>
        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleButtonMove}>
            Move
          </button>
          <button
            className={styles.actionButton}
            onClick={handleButtonCancel}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
