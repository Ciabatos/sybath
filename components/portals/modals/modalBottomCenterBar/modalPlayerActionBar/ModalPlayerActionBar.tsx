import styles from "@/components/portals/modals/ModalBottomCenterBar/styles/ModalActionBar.module.css"
import { Button } from "@/components/ui/button"
import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"

export default function ModalPlayerActionBar() {
  const { getClickedMapTile } = useMapTileActions()
  const { newMapTilesActionStatus } = useMapTilesActionStatus()

  const handleButtonMove = () => {
    newMapTilesActionStatus.MovementAction()
  }

  const handleButtonGuardArea = () => {
    newMapTilesActionStatus.GuardAreaAction()
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          Player Actions on Tile {getClickedMapTile()?.mapTile.x}, {getClickedMapTile()?.mapTile.y}
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
