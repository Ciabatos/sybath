import styles from "@/components/portals/modals/ModalBottomCenterBar/styles/ModalActionBar.module.css"
import { Button } from "@/components/ui/button"
import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import Link from "next/link"

export default function ModalCityActionBar() {
  const { getClickedMapTile } = useMapTileActions()
  const { resetMapTilesActionStatus } = useMapTilesActionStatus()

  const handleButtonEnter = () => {
    resetMapTilesActionStatus()
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
          <Link href={`/city/${getClickedMapTile()?.cities?.id}`}>
            <Button
              className={styles.actionButton}
              onClick={handleButtonEnter}>
              Enter
            </Button>
          </Link>
        </div>
      </div>
    </div>
  )
}
