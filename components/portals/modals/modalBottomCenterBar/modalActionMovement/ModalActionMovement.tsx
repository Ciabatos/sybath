"use client"
import styles from "@/components/portals/modals/ModalBottomCenterBar/modalActionMovement/styles/ModalActionMovement.module.css"
import { useActionMapTilesMovement } from "@/methods/hooks/map/composite/useActionMapTilesMovement"
import { useMapTileActions } from "@/methods/hooks/map/composite/useMapTileActions"
import { useMapTilesActionStatus } from "@/methods/hooks/map/composite/useMapTilesActionStatus"
import { usePlayerPositionMapTile } from "@/methods/hooks/mapTiles/composite/usePlayerPositionMapTile"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useEffect } from "react"

export default function ModalActionMovement() {
  const { playerMapTile } = usePlayerPositionMapTile()
  const { getClickedMapTile } = useMapTileActions()
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } = useActionMapTilesMovement()
  const { newMapTilesActionStatus } = useMapTilesActionStatus()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()

  useEffect(() => {
    selectMapTilesMovementPath(playerMapTile, getClickedMapTile())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [getClickedMapTile()])

  function handleMove() {
    mutateActionTaskInProcess(mapTilesMovementPathSet)
    doPlayerMovementAction()
    newMapTilesActionStatus.PlayerActionList()
  }

  function resetMove() {
    newMapTilesActionStatus.PlayerActionList()
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Tile to move to from tiles</p>
          <p>
            Movement path : {playerMapTile?.mapTile.x}, {playerMapTile?.mapTile.y} to {getClickedMapTile()?.mapTile.x}, {getClickedMapTile()?.mapTile.y}
          </p>
        </div>
        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleMove}>
            Move
          </button>
          <button
            className={styles.actionButton}
            onClick={resetMove}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
