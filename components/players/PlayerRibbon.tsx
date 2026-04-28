"use client"
import PlayerPortrait from "@/components/players/PlayerPortrait"
import PlayerSwitchButton from "@/components/players/PlayerSwitchButton"
import SquadPortrait from "@/components/squad/SquadPortrait"
import SquadSwitchButton from "@/components/squad/SquadSwitchButton"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useActivePlayerProfile } from "@/methods/hooks/players/composite/useActivePlayerProfile"
import { useActivePlayerSquad } from "@/methods/hooks/squad/composite/useActivePlayerSquad"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import styles from "./styles/PlayerRibbon.module.css"

export default function PlayerRibbon() {
  const { openModalLeftTopBar } = useModalLeftTopBar()
  const { activePlayerProfile } = useActivePlayerProfile()
  const { activePlayerSquad } = useActivePlayerSquad()
  const { openModalTopCenter } = useModalTopCenter()

  if (!activePlayerProfile) return null

  const handleClickPlayerPortrait = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PlayerPanel)
  }

  const handleClickPlayerSquadPortrait = () => {
    if (!activePlayerSquad) {
      openModalTopCenter(EPanelsTopCenter.SquadControls)
    } else {
      openModalLeftTopBar(EPanelsLeftTopBar.PlayerSquad)
    }
  }

  return (
    <>
      <Button
        onClick={handleClickPlayerPortrait}
        className={styles.heroButton}
      >
        <PlayerPortrait imagePortrait={activePlayerProfile.imagePortrait} />
      </Button>
      <div className={styles.switchButtonContainer}>
        <PlayerSwitchButton />
      </div>
      <div className={styles.squadPortraitWrapper}>
        <Button
          onClick={handleClickPlayerSquadPortrait}
          className={styles.squadButton}
        >
          <SquadPortrait squadImagePortrait={activePlayerSquad?.squadImagePortrait} />
        </Button>
        <div className={styles.switchButtonContainer}>
          <SquadSwitchButton />
        </div>
      </div>
    </>
  )
}
