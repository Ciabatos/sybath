import styles from "@/components/panels/styles/PanelActionBar.module.css"
import { Button } from "@/components/ui/button"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import Link from "next/link"

type TParams = {
  closePanel: () => void
}

export default function PanelCityActionBar({ closePanel }: TParams) {
  const { getClickedMapTile } = useMapTileActions()

  const handleButtonEnter = () => {
    closePanel()
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
              onClick={handleButtonEnter}
            >
              Enter
            </Button>
          </Link>
        </div>
      </div>
    </div>
  )
}
