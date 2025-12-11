import styles from "@/components/panels/styles/PanelActionBar.module.css"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { EPanels } from "@/types/enumeration/EPanels"
import Link from "next/link"

export default function PanelCityActionBar() {
  const { getClickedMapTile } = useMapTileActions()
  const { setStatus } = useModalRightCenter()

  const handleButtonEnter = () => {
    setStatus(EPanels.Inactive)
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
