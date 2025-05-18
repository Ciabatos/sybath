import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionBar.module.css"
import { Button } from "@/components/ui/button"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"
export default function ModalMapTilesCityActionBar() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  const handleButtonEnter = () => {
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
            onClick={handleButtonEnter}>
            Enter
          </Button>
        </div>
      </div>
    </div>
  )
}
