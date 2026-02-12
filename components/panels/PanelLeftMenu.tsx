"use client"

import PlayerPortrait from "@/components/players/PlayerPortrait"
import PlayerSquadPortrait from "@/components/players/PlayerSquadPortrait"
import PlayerSwitchButton from "@/components/players/PlayerSwitchButton"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import styles from "./styles/PanelLeftMenu.module.css"

export default function PanelLeftMenu() {
  const { openModalLeftTopBar } = useModalLeftTopBar()

  const handleClickPlayerPortrait = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPanel)
  }

  const handleClickPlayerSquadPortrait = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerSquad)
  }

  return (
    <div>
      <Button
        onClick={handleClickPlayerPortrait}
        className={styles.heroButton}
        size='icon'
      >
        <PlayerPortrait />
      </Button>
      <div className={styles.playerSwitchButtonContainer}>
        <PlayerSwitchButton />
      </div>
      <div className={styles.squadPortraitWrapper}>
        <Button
          onClick={handleClickPlayerSquadPortrait}
          className={styles.squadButton}
          size='icon'
        >
          <PlayerSquadPortrait />
        </Button>
      </div>
    </div>
  )
}
