"use client"
import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionMovment.module.css"
import { useActionMapTilesMovement } from "@/methods/hooks/playerMapTilesActions/useActionMapTilesMovement"

export default function ModalMapTilesActionMovment() {
  const { startingPoint, endingPoint, handleButtonMove, handleButtonCancel } = useActionMapTilesMovement()

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Tile to move to from tiles</p>
          <p>
            Movment path : {startingPoint?.x}, {startingPoint?.y} to {endingPoint?.x}, {endingPoint?.y}
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
