"use client"

import PlayerPortrait from "@/components/players/PlayerPortrait"
import PlayerSquadPortrait from "@/components/players/PlayerSquadPortrait"
import PlayerSwitchButton from "@/components/players/PlayerSwitchButton"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useActivePlayerProfile } from "@/methods/hooks/players/composite/useActivePlayerProfile"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import styles from "./styles/PanelLeftSidebarPlayerMenu.module.css"

export default function PanelLeftSidebarPlayerMenu() {
  const { openModalLeftTopBar } = useModalLeftTopBar()
  const { activePlayerProfile } = useActivePlayerProfile()

  if (!activePlayerProfile) return null

  const handleClickPlayerPortrait = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPanel)
  }

  const handleClickPlayerSquadPortrait = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerSquad)
  }

  return (
    <>
      <Button
        onClick={handleClickPlayerPortrait}
        className={styles.heroButton}
      >
        <PlayerPortrait imagePortrait={activePlayerProfile.imagePortrait} />
      </Button>
      <div className={styles.playerSwitchButtonContainer}>
        <PlayerSwitchButton />
      </div>
      <div className={styles.squadPortraitWrapper}>
        <Button
          onClick={handleClickPlayerSquadPortrait}
          className={styles.squadButton}
        >
          <PlayerSquadPortrait />
        </Button>
      </div>
    </>
  )
}
