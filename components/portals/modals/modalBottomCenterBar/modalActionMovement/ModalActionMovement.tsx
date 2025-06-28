"use client"
import styles from "@/components/portals/modals/ModalBottomCenterBar/modalActionMovement/styles/ModalActionMovement.module.css"
import { useActionMapTilesMovement } from "@/methods/hooks/mapTiles/composite/useActionMapTilesMovement"
import { useMapTilesManipulation } from "@/methods/hooks/mapTiles/composite/useMapTilesManipulation"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useEffect, useState } from "react"

export default function ModalActionMovement() {
  const { clickedTile } = useMapTilesManipulation()
  const [startingPoint] = useState(clickedTile)
  const { selectMapTilesMovementPath, mapTilesMovementPath, doPlayerMovementAction } = useActionMapTilesMovement()
  const { resetMapTilesActionStatus } = useMapTilesActionStatus()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()

  useEffect(() => {
    selectMapTilesMovementPath(startingPoint, clickedTile)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  function handleMove() {
    mutateActionTaskInProcess(mapTilesMovementPath)
    doPlayerMovementAction()
    resetMapTilesActionStatus()
  }

  function resetMove() {
    resetMapTilesActionStatus()
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Tile to move to from tiles</p>
          <p>
            Movement path : {startingPoint?.mapTile.x}, {startingPoint?.mapTile.y} to {clickedTile?.mapTile.x}, {clickedTile?.mapTile.y}
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
