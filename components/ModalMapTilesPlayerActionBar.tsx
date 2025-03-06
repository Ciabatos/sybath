import styles from "@/components/styles/ModalMapTilesPlayerActionBar.module.css"
import { usePlayerActionMapTilesMovement } from "@/methods/hooks/usePlayerActionMapTilesMovement"
import { clickedTileAtom, openModalBottomCenterBarAtom } from "@/store/atoms"
import { EModalStatus } from "@/types/enumeration/ModalBottomCenterBarEnum"
import { useAtomValue, useSetAtom } from "jotai"

export default function ModalMapTilesPlayerActionBar() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const setOpenModalBottomCenterBar = useSetAtom(openModalBottomCenterBarAtom)

  const { playerActionMapTilesMovement } = usePlayerActionMapTilesMovement()

  const handleMove = () => {
    playerActionMapTilesMovement(clickedTile)
  }

  const handleAttack = () => {
    setOpenModalBottomCenterBar(EModalStatus.Inactive)
  }

  const handleInteract = () => {
    setOpenModalBottomCenterBar(EModalStatus.Inactive)
  }

  const handleInspect = () => {
    setOpenModalBottomCenterBar(EModalStatus.Inactive)
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
            onClick={handleInteract}>
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
