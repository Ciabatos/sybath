"use client"
import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesPlayerActionMovment.module.css"
import { usePlayerActionMapTilesMovement } from "@/methods/hooks/usePlayerActionMapTilesMovement"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export default function ModalMapTilesPlayerActionMovment() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const [startingPoint] = useState(clickedTile)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)
  const { playerActionMapTilesMovement } = usePlayerActionMapTilesMovement()

  useEffect(() => {
    if (startingPoint && clickedTile) {
      playerActionMapTilesMovement(startingPoint, clickedTile)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleMove = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  const handleMoveCancel = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Tile to move to from tiles</p>
          <p>
            Movment path : {startingPoint?.x}, {startingPoint?.y} to {clickedTile?.x}, {clickedTile?.y}
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
            onClick={handleMoveCancel}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
