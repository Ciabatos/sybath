"use client"

import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionGuardArea.module.css"
import { useActionMapTilesGuardArea } from "@/methods/hooks/playerMapTilesActions/useActionMapTilesGuardArea"
import { useActionMapTilesMovement } from "@/methods/hooks/playerMapTilesActions/useActionMapTilesMovement"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export default function ModalMapTilesActionGuardArea() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const [startingPoint] = useState(clickedTile)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)
  const { actionMapTilesMovement } = useActionMapTilesMovement()
  const { actionMapTilesGuardArea } = useActionMapTilesGuardArea()

  useEffect(() => {
    if (startingPoint && clickedTile) {
      actionMapTilesMovement(startingPoint, clickedTile)
      actionMapTilesGuardArea(clickedTile)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleGuardArea = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  const handleCancel = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Guard Area</p>
          <p>
            Guard Area Radius from {clickedTile?.x}, {clickedTile?.y}
          </p>
        </div>
        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleGuardArea}>
            Guard Area
          </button>
          <button
            className={styles.actionButton}
            onClick={handleCancel}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
