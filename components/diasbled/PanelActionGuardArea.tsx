"use client"

import styles from "@/components/panels/styles/PanelActionGuardArea.module.css"
import { usePlayerPositionMapTile } from "@/methods/hooks/mapTiles/composite/usePlayerPositionMapTile"
import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"
import { useActionMapTilesGuardArea } from "@/methods/hooks/players/composite/useActionMapTilesGuardArea"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { EPanels } from "@/types/enumeration/EPanels"
import { useEffect } from "react"

export default function PanelActionGuardArea() {
  const { playerMapTile } = usePlayerPositionMapTile()
  const { getClickedMapTile } = useMapTileActions()
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } =
    useMapTilesPathFromPointToPoint()
  const { selectMapTilesGuardArea } = useActionMapTilesGuardArea()
  const { setStatus } = useModalBottomCenterBar()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()

  useEffect(() => {
    selectMapTilesMovementPath(playerMapTile, getClickedMapTile())
    selectMapTilesGuardArea(playerMapTile, getClickedMapTile())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [getClickedMapTile()])

  function handleGuardArea() {
    mutateActionTaskInProcess(mapTilesMovementPathSet)
    doPlayerMovementAction()
    setStatus(EPanels.PanelPlayerActionBar)
  }

  function resetGuardArea() {
    setStatus(EPanels.PanelPlayerActionBar)
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Guard Area</p>
          <p>
            Guard Area Radius from {getClickedMapTile()?.tiles.x}, {getClickedMapTile()?.tiles.y}
          </p>
        </div>
        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleGuardArea}
          >
            Guard Area
          </button>
          <button
            className={styles.actionButton}
            onClick={resetGuardArea}
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
