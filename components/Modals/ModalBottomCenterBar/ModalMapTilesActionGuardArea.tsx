"use client"

import styles from "@/components/Modals/ModalBottomCenterBar/styles/ModalMapTilesActionGuardArea.module.css"
import { useActionMapTilesGuardArea } from "@/methods/hooks/playerMapTilesActions/useActionMapTilesGuardArea"

export default function ModalMapTilesActionGuardArea() {
  const { endingPoint, handleButtonGuardArea, handleButtonCancel } = useActionMapTilesGuardArea()

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Guard Area</p>
          <p>
            Guard Area Radius from {endingPoint?.mapTile.x}, {endingPoint?.mapTile.y}
          </p>
        </div>
        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleButtonGuardArea}>
            Guard Area
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
