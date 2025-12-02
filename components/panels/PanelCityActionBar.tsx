import styles from "@/components/panels/styles/PanelActionBar.module.css"
import { Button } from "@/components/ui/button"
import { useModal } from "@/methods/hooks/modals/useModal"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import Link from "next/link"

export default function PanelCityActionBar() {
  const { getClickedMapTile } = useMapTileActions()
  const { resetMapTilesActionStatus } = useModal()

  const handleButtonEnter = () => {
    resetMapTilesActionStatus()
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          Player Actions on Tile {getClickedMapTile()?.tiles.x}, {getClickedMapTile()?.tiles.y}
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
