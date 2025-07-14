"use client"

import styles from "@/components/portals/modals/ModalBottomCenterBar/modalActionGuardArea/styles/ModalActionGuardArea.module.css"
import { useActionMapTilesGuardArea } from "@/methods/hooks/mapTiles/composite/useActionMapTilesGuardArea"
import { useActionMapTilesMovement } from "@/methods/hooks/mapTiles/composite/useActionMapTilesMovement"
import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { usePlayerPositionMapTile } from "@/methods/hooks/mapTiles/composite/usePlayerPositionMapTile"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useEffect } from "react"

export default function ModalActionGuardArea() {
  const { playerMapTile } = usePlayerPositionMapTile()
  const { getClickedMapTile } = useMapTileActions()
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } = useActionMapTilesMovement()
  const { selectMapTilesGuardArea } = useActionMapTilesGuardArea()
  const { newMapTilesActionStatus } = useMapTilesActionStatus()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()

  useEffect(() => {
    selectMapTilesMovementPath(playerMapTile, getClickedMapTile())
    selectMapTilesGuardArea(playerMapTile, getClickedMapTile())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [getClickedMapTile()])

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
            Guard Area Radius from {getClickedMapTile()?.mapTile.x}, {getClickedMapTile()?.mapTile.y}
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
