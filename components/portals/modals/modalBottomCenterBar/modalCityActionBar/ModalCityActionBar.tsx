import styles from "@/components/portals/modals/ModalBottomCenterBar/styles/ModalActionBar.module.css"
import { Button } from "@/components/ui/button"
import { useMapTilesManipulation } from "@/methods/hooks/mapTiles/composite/useMapTilesManipulation"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import Link from "next/link"

export default function ModalCityActionBar() {
  const { clickedTile } = useMapTilesManipulation()
  const { resetMapTilesActionStatus } = useMapTilesActionStatus()

  const handleButtonEnter = () => {
    resetMapTilesActionStatus()
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
          <Link href={`/city/${clickedTile?.cities?.id}`}>
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
