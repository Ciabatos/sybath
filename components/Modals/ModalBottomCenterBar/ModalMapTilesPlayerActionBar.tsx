import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionBar.module.css"
import { Button } from "@/components/ui/button"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"
export default function ModalMapTilesPlayerActionBar() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  const handleButtonMove = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.MovementAction)
  }

  const handleButtonGuardArea = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.GuardAreaAction)
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          Player Actions on Tile {clickedTile?.mapTile.x}, {clickedTile?.mapTile.y}
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
            onClick={handleButtonGuardArea}>
            Guar Area
          </Button>
        </div>
      </div>
    </div>
  )
}
