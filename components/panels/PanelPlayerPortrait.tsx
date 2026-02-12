"use client"

import PlayerPortrait from "@/components/players/PlayerPortrait"
import PlayerSwitchButton from "@/components/players/PlayerSwitchButton"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import styles from "./styles/PanelPlayerPortrait.module.css"

export default function PanelPlayerPortrait() {
  const { openModalLeftTopBar } = useModalLeftTopBar()

  const handleClick = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPanel)
  }

  return (
    <div>
      <Button
        onClick={handleClick}
        className={styles.heroButton}
        size='icon'
      >
        <PlayerPortrait />
      </Button>
      <div className={styles.playerSwitchButtonContainer}>
        <PlayerSwitchButton />
      </div>
    </div>
  )
}
