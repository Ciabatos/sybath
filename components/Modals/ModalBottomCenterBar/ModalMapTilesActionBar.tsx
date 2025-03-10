import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionBar.module.css"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { Button } from "@heroui/button"
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
          <Button
            className={styles.actionButton}
            onPress={handleMove}>
            Move
          </Button>
          <Button
            className={styles.actionButton}
            onPress={handleAttack}>
            Interact
          </Button>
          <Button
            className={styles.actionButton}
            onPress={handleInteract}>
            Attack
          </Button>
          <Button
            className={styles.actionButton}
            onPress={handleGuardArea}>
            Guar Area
          </Button>
          <Button
            className={styles.actionButton}
            onPress={handleInspect}>
            Build
          </Button>
          <Button
            className={styles.actionButton}
            onPress={handleInspect}>
            Inspect
          </Button>
        </div>
      </div>
    </div>
  )
}
