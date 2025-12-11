"use client"
import styles from "@/components/panels/styles/PanelActionMovement.module.css"
import { usePlayerPositionMapTile } from "@/methods/hooks/mapTiles/composite/usePlayerPositionMapTile"
import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { EPanels } from "@/types/enumeration/EPanels"
import { useEffect } from "react"

export default function PanelActionMovement() {
  const { playerMapTile } = usePlayerPositionMapTile()
  const { getClickedMapTile } = useMapTileActions()
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } =
    useMapTilesPathFromPointToPoint()
  const { setStatus } = useModalBottomCenterBar()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()

  useEffect(() => {
    selectMapTilesMovementPath(playerMapTile, getClickedMapTile())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [getClickedMapTile()])

  function handleMove() {
    mutateActionTaskInProcess(mapTilesMovementPathSet)
    doPlayerMovementAction()
    setStatus(EPanels.PanelPlayerActionBar)
  }

  function resetMove() {
    setStatus(EPanels.PanelPlayerActionBar)
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Tile to move to from tiles</p>
          <p>
            Movement path : {playerMapTile?.mapTile.x}, {playerMapTile?.mapTile.y} to {getClickedMapTile()?.tiles.x},{" "}
            {getClickedMapTile()?.tiles.y}
          </p>
        </div>
        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleMove}
          >
            Move
          </button>
          <button
            className={styles.actionButton}
            onClick={resetMove}
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
