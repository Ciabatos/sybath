"use client"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { Users } from "lucide-react"
import styles from "./styles/PanelPlayerSquadPortrait.module.css"

export default function PanelPlayerSquadPortrait() {
  const squadSize = 4
  const { openModalLeftTopBar } = useModalLeftTopBar()

  const handleClick = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerSquad)
  }

  return (
    <div className={styles.squadPortraitWrapper}>
      <Button
        onClick={handleClick}
        className={styles.squadButton}
        size='icon'
      >
        <div className={styles.iconWrapper}>
          <Users className={styles.squadIcon} />
          <span className={styles.squadBadge}>{squadSize}</span>
          <span className={styles.squadLabel}>Squad</span>
        </div>
      </Button>
    </div>
  )
}
