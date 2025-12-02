"use client"
import styles from "@/components/panels/styles/PanelActionMovement.module.css"
import { usePlayerPositionMapTile } from "@/methods/hooks/mapTiles/composite/usePlayerPositionMapTile"
import { useModal } from "@/methods/hooks/modals/useModal"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useActionMapTilesMovement } from "@/methods/hooks/world/composite/useActionMapTilesMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useEffect } from "react"

export default function PanelActionMovement() {
  const { playerMapTile } = usePlayerPositionMapTile()
  const { getClickedMapTile } = useMapTileActions()
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } = useActionMapTilesMovement()
  const { newMapTilesActionStatus } = useModal()
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
            Movement path : {playerMapTile?.mapTile.x}, {playerMapTile?.mapTile.y} to {getClickedMapTile()?.tiles.x}, {getClickedMapTile()?.tiles.y}
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
