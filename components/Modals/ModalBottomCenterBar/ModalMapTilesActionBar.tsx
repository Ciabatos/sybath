import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionBar.module.css"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"

export default function ModalMapTilesActionBar() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  const handleMove = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.MovementAction)
  }

  const handleAttack = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  const handleGuardArea = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.GuardAreaAction)
  }

  const handleInteract = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  const handleInspect = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          Player Actions on Tile {clickedTile?.x}, {clickedTile?.y}
        </div>
      </div>

      <div className={styles.modalContent}>
        <div>Select an action to perform on this tile.</div>

        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleMove}>
            Move
          </button>
          <button
            className={styles.actionButton}
            onClick={handleAttack}>
            Interact
          </button>
          <button
            className={styles.actionButton}
            onClick={handleInteract}>
            Attack
          </button>
          <button
            className={styles.actionButton}
            onClick={handleGuardArea}>
            Guar Area
          </button>
          <button
            className={styles.actionButton}
            onClick={handleInspect}>
            Build
          </button>
          <button
            className={styles.actionButton}
            onClick={handleInspect}>
            Inspect
          </button>
        </div>
      </div>
    </div>
  )
}
