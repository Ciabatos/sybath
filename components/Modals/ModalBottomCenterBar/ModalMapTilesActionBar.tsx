import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionBar.module.css"
import { Button } from "@/components/ui/button"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"
export default function ModalMapTilesActionBar() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  const handleButtonMove = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.MovementAction)
  }

  const handleButtonAttack = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  const handleButtonGuardArea = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.GuardAreaAction)
  }

  const handleButtonInteract = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  const handleButtonInspect = () => {
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
            onClick={handleButtonMove}>
            Move
          </Button>
          <Button
            className={styles.actionButton}
            onClick={handleButtonAttack}>
            Interact
          </Button>
          <Button
            className={styles.actionButton}
            onClick={handleButtonInteract}>
            Attack
          </Button>
          <Button
            className={styles.actionButton}
            onClick={handleButtonGuardArea}>
            Guar Area
          </Button>
          <Button
            className={styles.actionButton}
            onClick={handleButtonInspect}>
            Build
          </Button>
          <Button
            className={styles.actionButton}
            onClick={handleButtonInspect}>
            Inspect
          </Button>
        </div>
      </div>
    </div>
  )
}
