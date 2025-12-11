import styles from "@/components/panels/styles/PanelActionBar.module.css"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { EPanels } from "@/types/enumeration/EPanels"

export default function PanelPlayerActionBar() {
  const { getClickedMapTile } = useMapTileActions()
  const { setStatus } = useModalLeftTopBar()

  const handleButtonMove = () => {
    setStatus(EPanels.PanelActionMovement)
  }

  const handleButtonGuardArea = () => {
    setStatus(EPanels.PanelActionGuardArea)
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
          <Button
            className={styles.actionButton}
            onClick={handleButtonMove}
          >
            Move
          </Button>

          <Button
            className={styles.actionButton}
            onClick={handleButtonGuardArea}
          >
            Guar Area
          </Button>
        </div>
      </div>
    </div>
  )
}
