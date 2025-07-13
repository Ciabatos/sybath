"use client"

import styles from "@/components/portals/modals/ModalBottomCenterBar/modalActionGuardArea/styles/ModalActionGuardArea.module.css"
import { useActionMapTilesGuardArea } from "@/methods/hooks/mapTiles/composite/useActionMapTilesGuardArea"
import { useActionMapTilesMovement } from "@/methods/hooks/mapTiles/composite/useActionMapTilesMovement"
import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useEffect, useState } from "react"

export default function ModalActionGuardArea() {
  const { clickedTile } = useMapTileActions()
  const [startingPoint] = useState(clickedTile)
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } = useActionMapTilesMovement()
  const { selectMapTilesGuardArea } = useActionMapTilesGuardArea()
  const { newMapTilesActionStatus } = useMapTilesActionStatus()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()

  useEffect(() => {
    selectMapTilesMovementPath(startingPoint, clickedTile)
    selectMapTilesGuardArea(startingPoint, clickedTile)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  function handleGuardArea() {
    mutateActionTaskInProcess(mapTilesMovementPathSet)
    doPlayerMovementAction()
    newMapTilesActionStatus.PlayerActionList()
  }

  function resetGuardArea() {
    newMapTilesActionStatus.PlayerActionList()
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Guard Area</p>
          <p>
            Guard Area Radius from {clickedTile?.mapTile.x}, {clickedTile?.mapTile.y}
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
            onClick={resetGuardArea}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
